
# LSDa: LINKSET DATA ARENA - OFFICIAL DOCUMENTATION by CapeXCat

## What is this?

LSDa (Linkset Data Arena) is a streamlined, high-speed Arena Allocator written in LSL. Unlike a dynamic heap that recycles individual keys, an arena allocates memory in massive contiguous blocks using simple integer identifiers (e.g., `m0`, `m1`). 

## Why has it been created?

Dynamic memory managers (like LSDm) carry overhead for tracking types, parsing strings, and managing free lists. Sometimes, a script simply needs pure speed and sequential access such as loading a static game grid or parsing bulk binary data. LSDa was created to strip away the overhead and provide blistering fast read/write speeds over large, fixed-size data sets.

## What features does it provide?

* **High Performance:** Relies entirely on integer math for addressing (`base + index`), completely bypassing string parsing during offset calculations.
* **Contiguous Allocation:** Ensures that when you request a block of memory, it occupies a perfectly sequential space in LSD.
* **Atomic Rollbacks:** If the arena fails to allocate a massive block (e.g., region LSD memory is full), it halts and deletes the partial allocation immediately.
* **Lean Footprint:** No garbage collector overhead. Once allocated, it belongs to the script until manually deleted or the script is reset.

## Functions Available & Detailed Usage

### MEMORY ALLOCATION

* `AllocateBlock(integer size, string type_prefix, string default_value)`
    * **Description:** Secures a sequential block of memory in the arena. If allocation fails, it cleans up and outputs a critical halt warning.
    * **Parameters:** `size` (amount of slots), `type_prefix` (e.g., "i"), `default_value`.
    * **Returns:** `integer` representing the base address. Returns `-1` on failure.
    * **Example:** `integer map_base = AllocateBlock(100, "i", "0");`

### READ/WRITE OPERATIONS

* `WriteRaw(integer addr, string typed_value)`
    * **Description:** Writes directly to the integer address.
    * **Parameters:** `addr` (the integer memory location), `typed_value` (e.g., "i:99").
    * **Returns:** `integer` (LSD write status).
    * **Example:** `WriteRaw(map_base + 5, "s:Monster");`

* `ReadRaw(integer addr)`
    * **Description:** Reads the raw stored value at the address.
    * **Returns:** The raw string or `"ERR_NULL"` if it doesn't exist.

* `WriteInt(integer addr, integer val)`
    * **Description:** Helper function to quickly write an integer with its type prefix.
    * **Returns:** `integer` (LSD write status).
    * **Example:** `WriteInt(map_base + 10, 404);`

* `ReadInt(integer addr)`
    * **Description:** Reads the data at the address, strips the first two characters (the type prefix), and returns an integer. Defaults to `0` if empty.
    * **Returns:** `integer`.
    * **Example:** `integer obj_id = ReadInt(map_base + 10);`

* `ReadString(integer addr)`
    * **Description:** Reads the string at the address, stripping the type prefix. Defaults to `""` if empty.
    * **Returns:** `string`.

### ADVANCED BLOCK OPERATIONS

* `MemCopy(integer dest_base, integer src_base, integer elements)`
    * **Description:** Copies data from one block to another using pure integer iteration. If it hits a null source, it clears the destination slot.
    * **Returns:** `integer` (TRUE/FALSE).
    * **Example:** `MemCopy(new_map, old_map, 100);`

* `MemSet(integer dest_base, string type_prefix, string value, integer elements)`
    * **Description:** Floods a block of addresses with a specific prefixed payload in a highly optimized loop.
    * **Returns:** `integer` (TRUE/FALSE).

## Why is it bug-free?

LSDa minimizes failure points through extreme simplicity. By enforcing integer-only addressing (`m0`, `m1`, `m2`), it removes the risk of string-parsing errors and bad list evaluations in LSL. Furthermore, its `AllocateBlock` guarantees atomicity: it verifies every write operation during allocation. If a single slot fails to write, it rolls back the entire block, guaranteeing you never end up with a fragmented or partially accessible array.

## Where can I use it?
LSDa is specifically designed for high-performance, static bulk-data loading. It is best used for initializing game maps, rigid data tables, voxel storage, or any scenario where memory is allocated once at startup and subsequently bombarded with rapid, constant read/write requests.
