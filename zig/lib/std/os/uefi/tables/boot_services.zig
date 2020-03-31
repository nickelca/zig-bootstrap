const uefi = @import("std").os.uefi;
const Event = uefi.Event;
const Guid = uefi.Guid;
const Handle = uefi.Handle;
const Status = uefi.Status;
const TableHeader = uefi.tables.TableHeader;
const DevicePathProtocol = uefi.protocols.DevicePathProtocol;

/// Boot services are services provided by the system's firmware until the operating system takes
/// over control over the hardware by calling exitBootServices.
///
/// Boot Services must not be used after exitBootServices has been called. The only exception is
/// getMemoryMap, which may be used after the first unsuccessful call to exitBootServices.
/// After successfully calling exitBootServices, system_table.console_in_handle, system_table.con_in,
/// system_table.console_out_handle, system_table.con_out, system_table.standard_error_handle,
/// system_table.std_err, and system_table.boot_services should be set to null. After setting these
/// attributes to null, system_table.hdr.crc32 must be recomputed.
///
/// As the boot_services table may grow with new UEFI versions, it is important to check hdr.header_size.
pub const BootServices = extern struct {
    hdr: TableHeader,

    /// Raises a task's priority level and returns its previous level.
    raiseTpl: extern fn (usize) usize,

    /// Restores a task's priority level to its previous value.
    restoreTpl: extern fn (usize) void,

    /// Allocates memory pages from the system.
    allocatePages: extern fn (AllocateType, MemoryType, usize, *[*]align(4096) u8) Status,

    /// Frees memory pages.
    freePages: extern fn ([*]align(4096) u8, usize) Status,

    /// Returns the current memory map.
    getMemoryMap: extern fn (*usize, [*]MemoryDescriptor, *usize, *usize, *u32) Status,

    /// Allocates pool memory.
    allocatePool: extern fn (MemoryType, usize, *[*]align(8) u8) Status,

    /// Returns pool memory to the system.
    freePool: extern fn ([*]align(8) u8) Status,

    /// Creates an event.
    createEvent: extern fn (u32, usize, ?extern fn (Event, ?*c_void) void, ?*const c_void, *Event) Status,

    /// Sets the type of timer and the trigger time for a timer event.
    setTimer: extern fn (Event, TimerDelay, u64) Status,

    /// Stops execution until an event is signaled.
    waitForEvent: extern fn (usize, [*]const Event, *usize) Status,

    /// Signals an event.
    signalEvent: extern fn (Event) Status,

    /// Closes an event.
    closeEvent: extern fn (Event) Status,

    /// Checks whether an event is in the signaled state.
    checkEvent: extern fn (Event) Status,

    installProtocolInterface: Status, // TODO
    reinstallProtocolInterface: Status, // TODO
    uninstallProtocolInterface: Status, // TODO

    /// Queries a handle to determine if it supports a specified protocol.
    handleProtocol: extern fn (Handle, *align(8) const Guid, *?*c_void) Status,

    reserved: *c_void,

    registerProtocolNotify: Status, // TODO

    /// Returns an array of handles that support a specified protocol.
    locateHandle: extern fn (LocateSearchType, ?*align(8) const Guid, ?*const c_void, *usize, [*]Handle) Status,

    locateDevicePath: Status, // TODO
    installConfigurationTable: Status, // TODO

    /// Loads an EFI image into memory.
    loadImage: extern fn (bool, Handle, ?*const DevicePathProtocol, ?[*]const u8, usize, *?Handle) Status,

    /// Transfers control to a loaded image's entry point.
    startImage: extern fn (Handle, ?*usize, ?*[*]u16) Status,

    /// Terminates a loaded EFI image and returns control to boot services.
    exit: extern fn (Handle, Status, usize, ?*const c_void) Status,

    /// Unloads an image.
    unloadImage: extern fn (Handle) Status,

    /// Terminates all boot services.
    exitBootServices: extern fn (Handle, usize) Status,

    /// Returns a monotonically increasing count for the platform.
    getNextMonotonicCount: extern fn (*u64) Status,

    /// Induces a fine-grained stall.
    stall: extern fn (usize) Status,

    /// Sets the system's watchdog timer.
    setWatchdogTimer: extern fn (usize, u64, usize, ?[*]const u16) Status,

    connectController: Status, // TODO
    disconnectController: Status, // TODO

    /// Queries a handle to determine if it supports a specified protocol.
    openProtocol: extern fn (Handle, *align(8) const Guid, *?*c_void, ?Handle, ?Handle, OpenProtocolAttributes) Status,

    /// Closes a protocol on a handle that was opened using openProtocol().
    closeProtocol: extern fn (Handle, *align(8) const Guid, Handle, ?Handle) Status,

    /// Retrieves the list of agents that currently have a protocol interface opened.
    openProtocolInformation: extern fn (Handle, *align(8) const Guid, *[*]ProtocolInformationEntry, *usize) Status,

    /// Retrieves the list of protocol interface GUIDs that are installed on a handle in a buffer allocated from pool.
    protocolsPerHandle: extern fn (Handle, *[*]*align(8) const Guid, *usize) Status,

    /// Returns an array of handles that support the requested protocol in a buffer allocated from pool.
    locateHandleBuffer: extern fn (LocateSearchType, ?*align(8) const Guid, ?*const c_void, *usize, *[*]Handle) Status,

    /// Returns the first protocol instance that matches the given protocol.
    locateProtocol: extern fn (*align(8) const Guid, ?*const c_void, *?*c_void) Status,

    installMultipleProtocolInterfaces: Status, // TODO
    uninstallMultipleProtocolInterfaces: Status, // TODO

    /// Computes and returns a 32-bit CRC for a data buffer.
    calculateCrc32: extern fn ([*]const u8, usize, *u32) Status,

    /// Copies the contents of one buffer to another buffer
    copyMem: extern fn ([*]u8, [*]const u8, usize) void,

    /// Fills a buffer with a specified value
    setMem: extern fn ([*]u8, usize, u8) void,

    createEventEx: Status, // TODO

    pub const signature: u64 = 0x56524553544f4f42;

    pub const event_timer: u32 = 0x80000000;
    pub const event_runtime: u32 = 0x40000000;
    pub const event_notify_wait: u32 = 0x00000100;
    pub const event_notify_signal: u32 = 0x00000200;
    pub const event_signal_exit_boot_services: u32 = 0x00000201;
    pub const event_signal_virtual_address_change: u32 = 0x00000202;

    pub const tpl_application: usize = 4;
    pub const tpl_callback: usize = 8;
    pub const tpl_notify: usize = 16;
    pub const tpl_high_level: usize = 31;
};

pub const TimerDelay = extern enum(u32) {
    TimerCancel,
    TimerPeriodic,
    TimerRelative,
};

pub const MemoryType = extern enum(u32) {
    ReservedMemoryType,
    LoaderCode,
    LoaderData,
    BootServicesCode,
    BootServicesData,
    RuntimeServicesCode,
    RuntimeServicesData,
    ConventionalMemory,
    UnusableMemory,
    ACPIReclaimMemory,
    ACPIMemoryNVS,
    MemoryMappedIO,
    MemoryMappedIOPortSpace,
    PalCode,
    PersistentMemory,
    MaxMemoryType,
};

pub const MemoryDescriptor = extern struct {
    type: MemoryType,
    physical_start: u64,
    virtual_start: u64,
    number_of_pages: usize,
    attribute: packed struct {
        uc: bool,
        wc: bool,
        wt: bool,
        wb: bool,
        uce: bool,
        _pad1: u7,
        wp: bool,
        rp: bool,
        xp: bool,
        nv: bool,
        more_reliable: bool,
        ro: bool,
        sp: bool,
        cpu_crypto: bool,
        _pad2: u43,
        memory_runtime: bool,
    },
};

pub const LocateSearchType = extern enum(u32) {
    AllHandles,
    ByRegisterNotify,
    ByProtocol,
};

pub const OpenProtocolAttributes = packed struct {
    by_handle_protocol: bool = false,
    get_protocol: bool = false,
    test_protocol: bool = false,
    by_child_controller: bool = false,
    by_driver: bool = false,
    exclusive: bool = false,
    _pad: u26 = undefined,
};

pub const ProtocolInformationEntry = extern struct {
    agent_handle: ?Handle,
    controller_handle: ?Handle,
    attributes: OpenProtocolAttributes,
    open_count: u32,
};

pub const AllocateType = extern enum(u32) {
    AllocateAnyPages,
    AllocateMaxAddress,
    AllocateAddress,
};