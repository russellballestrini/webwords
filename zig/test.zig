const std = @import("std"); const http = std.http; pub fn main() \!void { std.debug.print("{}", .{@typeInfo(http)}); }
