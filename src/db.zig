const std = @import("std");
const sqlite = @import("sqlite");
const types = @import("types.zig");

pub const EmotionDatabase = struct {
    // inicializacion
    db: sqlite.Db,

    // funcion de init
    pub fn init(db_path: [:0]const u8) !EmotionDatabase {
        const db = try sqlite.Db.init(.{
            .mode = sqlite.Db.Mode{ .File = db_path },
            .open_flags = .{
                .write = true,
                .create = true,
            },
            .threading_mode = .MultiThread,
        });
        return EmotionDatabase{ .db = db };
    }

    //funcion de deinit
    pub fn deinit(self: *EmotionDatabase) void {
        self.db.deinit();
    }

    // encapsulamiento de creacion de tablas
    pub fn setupSchema(self: *EmotionDatabase) !void {
        const query =
            \\ create table if not exists emotion(
            \\ id integer primary key,
            \\ name text,
            \\ cause text,
            \\ weight integer,
            \\ created_at datetime default current_timestamp
            \\ )
        ;
        try self.db.exec(query, .{}, .{});
    }

    //encapsualcion de consultas especificas por dominio

    // getall emociones

    pub fn fetchEmotions(self: *EmotionDatabase) !void {
        const query = "select id,name,cause,weight from emotion";
        var stmt = try self.db.prepare(query);
        defer stmt.deinit();
        var iter = try stmt.iterator(types.EmotionRow, .{});
        while (try iter.next(.{})) |row| {
            const clean_name = std.mem.sliceTo(&row.name, 0);
            const clean_cause = std.mem.sliceTo(&row.cause, 0);
            std.debug.print("-> Emocion: \n{s}\n--> Causa: \n{s}\n-->Peso: \n{d}\n\n", .{ clean_name, clean_cause, row.weight });
        }
    }

    // select de emociones por peso
    pub fn fetchEmotionsByWeight(self: *EmotionDatabase, min_weight: i32) !void {
        const query = "select id, name, cause, weight from emotion where weight > ?";
        var stmt = try self.db.prepare(query);
        defer stmt.deinit();
        var iter = try stmt.iterator(types.EmotionRow, .{min_weight});
        while (try iter.next(.{})) |row| {
            std.debug.print("-> Emocion: {s} \n->Peso: {d}\n\n", .{ row.name, row.weight });
        }
    }

    //

    // insert de emocion
    pub fn insertEmotion(self: *EmotionDatabase, name: []const u8, cause: []const u8, weight: i32) !void {
        const query =
            \\insert into emotion (name,cause,weight) values (?,?,?)
        ;
        var stmt = try self.db.prepare(query);
        defer stmt.deinit();

        try stmt.exec(.{}, .{
            .name = name,
            .cause = cause,
            .weight = weight,
        });
    }

    // delete registro

    pub fn deleteEmotion(self: *EmotionDatabase, id_to_delete: i32) !void {
        const query = "delete from emotion where id = ?";
        var stmt = try self.db.prepare(query);
        defer stmt.deinit();

        try stmt.exec(.{}, .{id_to_delete});
    }

    //fin de struct

};
