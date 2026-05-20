const std = @import("std");

//codigos ansi de colores

pub const Color = struct {
    pub const reset = "\x1B[0m";
    pub const red = "\x1B[31m";
    pub const green = "\x1B[32m";
    pub const blue = "\x1B[34m";
    pub const cyan = "\x1B[36m";
    pub const yellow = "\x1B[33m";
    pub const bold = "\x1B[1m";
};

// Limpia la pantalla y pone el cursor arriba
pub fn clearScreen(writer: anytype) !void {
    try writer.writeAll("\x1B[2J\x1B[H");
}
pub fn printTitle(writer: anytype, title: []const u8) !void {
    try writer.print("{s}{s}=== {s} ==={s}\n\n", .{ Color.bold, Color.cyan, title, Color.reset });
}
pub fn printError(writer: anytype, msg: []const u8) !void {
    try writer.print("\n{s}X_x ERROR: {s}{s}\n", .{ Color.red, msg, Color.reset });
}

// Imprime un mensaje de éxito en verde
pub fn printSuccess(writer: anytype, msg: []const u8) !void {
    try writer.print("\n{s}=) Éxito:{s} {s}\n", .{ Color.green, Color.reset, msg });
}
// Imprime el menú principal
pub fn printMenu(writer: anytype) !void {
    try writer.print(
        \\{s}1.{s} Añadir emoción
        \\{s}2.{s} Remover emoción
        \\{s}3.{s} Listar emociones
        \\{s}0.{s} Salir
        \\
        \\{s}Elige una opción:{s} 
    , .{ Color.yellow, Color.reset, Color.yellow, Color.reset, Color.yellow, Color.reset, Color.yellow, Color.reset, Color.bold, Color.reset });
}
pub fn pauseAndContinue(writer: anytype, reader: anytype) !void {
    try writer.print("\n{s}Presiona Enter para continuar...{s}", .{ Color.blue, Color.reset });
    _ = try reader.takeDelimiterExclusive('\n');
    reader.toss(1);
}
