// ==============================================================================
// LSDa: LINKSET DATA ARENA by CapeXCat
// ==============================================================================
integer g_next_address = 0;
integer g_active_allocations = 0;
// ==============================================================================
// MEMORY ALLOCATION
// ==============================================================================
integer AllocateBlock(integer size, string type_prefix, string default_value) {
    if (size <= 0) return -1;
    integer base_addr = g_next_address;
    integer i;

    for (i = 0; i < size; i++) {
        string ptr = "m" + (string)(base_addr + i);
        if (llLinksetDataWrite(ptr, type_prefix + ":" + default_value) != 0) {
            integer j;
            for (j = 0; j < i; j++) llLinksetDataDelete("m" + (string)(base_addr + j));
            g_active_allocations -= i;
            llOwnerSay("CRITICAL HALT: Arena Allocation Failed.");
            return -1;
        }
        g_active_allocations++;
    }
    g_next_address += size;
    return base_addr;
}
// ==============================================================================
// READ/WRITE OPERATIONS
// ==============================================================================
integer WriteRaw(integer addr, string typed_value) {
    return llLinksetDataWrite("m" + (string)addr, typed_value);
}
string ReadRaw(integer addr) {
    string raw = llLinksetDataRead("m" + (string)addr);
    if (raw == "") return "ERR_NULL";
    return raw;
}
integer WriteInt(integer addr, integer val) {
    return llLinksetDataWrite("m" + (string)addr, "i:" + (string)val);
}
integer ReadInt(integer addr) {
    string raw = llLinksetDataRead("m" + (string)addr);
    if (raw == "") return 0;
    return (integer)llDeleteSubString(raw, 0, 1);
}
string ReadString(integer addr) {
    string raw = llLinksetDataRead("m" + (string)addr);
    if (raw == "") return "";
    return llDeleteSubString(raw, 0, 1);
}
// ==============================================================================
// ADVANCED BLOCK OPERATIONS
// ==============================================================================
integer MemCopy(integer dest_base, integer src_base, integer elements) {
    if (elements <= 0) return FALSE;
    integer i;
    for (i = 0; i < elements; i++) {
        string val = ReadRaw(src_base + i);
        if (val == "ERR_NULL") {
            WriteRaw(dest_base + i, "");
        } else {
            WriteRaw(dest_base + i, val);
        }
    }
    return TRUE;
}
integer MemSet(integer dest_base, string type_prefix, string value, integer elements) {
    if (elements <= 0) return FALSE;
    integer i;
    string payload = type_prefix + ":" + value;
    for (i = 0; i < elements; i++) {
        llLinksetDataWrite("m" + (string)(dest_base + i), payload);
    }
    return TRUE;
}
// ==============================================================================
// DEFAULT STATE ENTRY
// ==============================================================================
default
{
    state_entry()
    {
    }
}
