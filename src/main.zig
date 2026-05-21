const std = @import("std");
const print = std.debug.print;
const EmotionDatabase = @import("db.zig").EmotionDatabase;
const ui = @import("ui.zig");
const zig_emotional_tracking = @import("zig_emotional_tracking");

pub fn main() !void {
    // var gpa = std.heap.smp_allocator
    //TODO
    //creamos el stdout
    var stdout_buffer: [1024]u8 = undefined;
    // try std.fs.
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.Io.Writer = &stdout_writer.interface;
    try stdout.print("Bienvenido a tu base de datos emocional! :D\n", .{});
    try stdout.flush();

    // creamoes el stdin
    var stdin_buffer: [1024]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
    const stdin: *std.Io.Reader = &stdin_reader.interface;

    var db = try EmotionDatabase.init("zigdata.db");
    defer db.deinit();
    try db.setupSchema();
    print("Configuracion inicial completada. \n", .{});
    var option: i8 = -1;

    while (option != 0) {

        // Este código mágico borra la pantalla en Linux/Mac y algunos Windows modernos
        try stdout.writeAll("\x1B[2J\x1B[H");
        try stdout.writeAll(
            \\1.añadir 
            \\2.remover
            \\3.listar
            \\0.salir
            \\:
        );
        try stdout.flush();

        // proceso de input
        const line = try stdin.takeDelimiterExclusive('\n');
        // toss the delimiter from the buffer so it is not processed
        stdin.toss(1);
        // en windows suele terminar con\r por eso se preprocesay limpia el texto
        const trimmed_line = std.mem.trimRight(u8, line, "\r");
        // if (trimmed_line == 0) continue;
        option = std.fmt.parseInt(i8, trimmed_line, 10) catch {
            print("\nError: por favor ingresa un número válido.\n", .{});
            continue;
        };
        switch (option) {
            1 => {
                // 1. Pedimos la emoción
                try stdout.writeAll(" Qué emoción sentiste hoy??\n: ");
                try stdout.flush();

                var raw = try stdin.takeDelimiterExclusive('\n');
                stdin.toss(1);
                var trimmed = std.mem.trimRight(u8, raw, "\r");

                // COPIAMOS A UNA CAJA SEGURA
                var emotion_buf: [128]u8 = undefined;
                @memcpy(emotion_buf[0..trimmed.len], trimmed);
                const emotion_name = emotion_buf[0..trimmed.len];

                // 2. Pedimos la causa
                try stdout.writeAll("¿Qué te hizo sentir así?\n: ");
                try stdout.flush();

                raw = try stdin.takeDelimiterExclusive('\n');
                stdin.toss(1);
                trimmed = std.mem.trimRight(u8, raw, "\r");

                // COPIAMOS A OTRA CAJA SEGURA
                var cause_buf: [1024]u8 = undefined;
                @memcpy(cause_buf[0..trimmed.len], trimmed);
                const cause_clean = cause_buf[0..trimmed.len];

                // 3. Pedimos el peso
                try stdout.writeAll("¿Qué tanto crees qué afecto tú dia?, dale ún número : ej. 1-10...\n: ");
                try stdout.flush();

                raw = try stdin.takeDelimiterExclusive('\n');
                stdin.toss(1);
                trimmed = std.mem.trimRight(u8, raw, "\r");

                // Aquí no necesitamos copiar memoria porque lo convertimos a número INMEDIATAMENTE
                const weight_num = std.fmt.parseInt(i32, trimmed, 10) catch 1;

                // 4. Insertamos en la Base de Datos
                try db.insertEmotion(emotion_name, cause_clean, weight_num);
                try stdout.writeAll(" Agregado con exito!! :3 , Felicitaciones por crear un registro en emotiondb.\n");
                try stdout.flush();
                try stdout.writeAll("\nPresiona Enter para continuar...");
                try stdout.flush();
                _ = try stdin.takeDelimiterExclusive('\n');
                stdin.toss(1);
            },
            2 => {
                try stdout.writeAll("Remover un registro\n");
                try stdout.flush();
            },
            3 => {
                try stdout.writeAll("Listar tus emociones :3\n");
                try stdout.flush();
                try db.fetchEmotions();
                try ui.pauseAndContinue(stdout, stdin);
            },
            0 => {
                try stdout.writeAll("Gracias por usar EmotionDatabase :3... Suerte!!");
                try stdout.flush();
                option = 0;
            },
            else => {
                try stdout.writeAll("\nOpción no válida. intenta de nuevo.\n");
                try stdout.flush();
            },
        }
    }
}
