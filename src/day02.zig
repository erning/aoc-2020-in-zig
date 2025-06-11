const std = @import("std");
const aoc = @import("./aoc.zig");
const utils = @import("./utils.zig");

const Tuple = std.meta.Tuple;

const Policy = struct {
    a: usize,
    b: usize,
    c: u8,
};

const ParseResultItem = struct { Policy, []const u8 };

fn parseInput(allocator: std.mem.Allocator, input: []const u8) ![]ParseResultItem {
    var result = std.ArrayList(ParseResultItem).init(allocator);
    defer result.deinit();

    var lines = std.mem.splitAny(u8, std.mem.trim(u8, input, "\n"), "\n");
    while (lines.next()) |line| {
        var parts = std.mem.splitAny(u8, line, "- :");
        var i: usize = 0;
        var parsed_parts: [5][]const u8 = undefined;
        while (parts.next()) |part| : (i += 1) {
            parsed_parts[i] = std.mem.trim(u8, part, " ");
        }

        const policy = Policy{
            .a = try std.fmt.parseInt(usize, parsed_parts[0], 10),
            .b = try std.fmt.parseInt(usize, parsed_parts[1], 10),
            .c = parsed_parts[2][0],
        };
        try result.append(.{ policy, parsed_parts[4] });
    }

    return result.toOwnedSlice();
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !usize {
    const entries = try parseInput(allocator, input);
    defer allocator.free(entries);

    var count: usize = 0;
    for (entries) |entry| {
        const policy = entry[0];
        const pwd = entry[1];
        var char_count: usize = 0;
        for (pwd) |c| {
            if (c == policy.c) {
                char_count += 1;
            }
        }
        if (char_count >= policy.a and char_count <= policy.b) {
            count += 1;
        }
    }
    return count;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !usize {
    const entries = try parseInput(allocator, input);
    defer allocator.free(entries);

    var count: usize = 0;
    for (entries) |entry| {
        const policy, const pwd = entry;
        const match1 = if (policy.a - 1 < pwd.len) pwd[policy.a - 1] == policy.c else false;
        const match2 = if (policy.b - 1 < pwd.len) pwd[policy.b - 1] == policy.c else false;
        if (match1 != match2) {
            count += 1;
        }
    }
    return count;
}

//

pub fn partOne(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .usize = try part1(allocator, input) };
}

pub fn partTwo(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .usize = try part2(allocator, input) };
}

// Unit test
test "day 02 example" {
    const allocator = std.testing.allocator;
    const input = try utils.readAsString(allocator, "./inputs/02-example.txt");
    defer allocator.free(input);

    const p1 = try part1(allocator, input);
    try std.testing.expectEqual(2, p1);

    const p2 = try part2(allocator, input);
    try std.testing.expectEqual(1, p2);
}
