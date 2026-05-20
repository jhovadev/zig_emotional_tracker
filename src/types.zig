pub const EmotionRow = struct {
    id: i32,
    name: [128:0]u8,
    cause: [1024:0]u8,
    weight: i32,
};

pub const Emotion = struct {
    name: []const u8,
    cause: []const u8,
    weight: i32,
};

pub const DbError = error{
    InitFailed,
    SchemaFailed,
    QueryFailed,
};
