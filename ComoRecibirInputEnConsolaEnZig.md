# Necesitamos la interfaz y la funcioón stdin/stdout

declaramos un buffer
var stdin_buffer = [1024]u8 = undefined;
var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
const stdin = &stdin_reader.interface;

while (stdin.takeByte()) |char| {
//  haz algho aui
std.debug.print("yu typed : {c}",.{char});
if (char == 'q') break;
}else |_| {}

var stdin_buffer: [1024 * 1024]u8 = undefined;
var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
const stdin = &stdin_reader.interface;

var alloc = std.heap.DebugAllocator(.{}).init;
defer _ = alloc.deinit();
const da = alloc.allocator();
var line_writer = std.Io.Writer.Allocating.init(da);
defer line_writer.deinit();

while (stdin.streamDelimiter(&line_writer.writer, '\n')) |_| {
    const line = line_writer.written();
    std.debug.print("{s}\n", .{line});
    line_writer.clearRetainingCapacity(); // empty the line buffer
    stdin.toss(1); // skip the newline
} else |err| if (err != error.EndOfStream) return err;

https://www.reddit.com/r/Zig/comments/1n03xx4/i_am_new_to_learning_zig_and_i_am_having_really/
