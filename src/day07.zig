const std = @import("std");
const aoc = @import("./aoc.zig");
const utils = @import("./utils.zig");

const Map = std.StringHashMap(std.StringHashMap(usize));

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !Map {
    var map = Map.init(allocator);
    errdefer {
        var iter = map.iterator();
        while (iter.next()) |entry| {
            // Free all keys in inner maps
            var inner_iter = entry.value_ptr.*.iterator();
            while (inner_iter.next()) |inner_entry| {
                allocator.free(inner_entry.key_ptr.*);
            }
            entry.value_ptr.deinit();
            allocator.free(entry.key_ptr.*);
        }
        map.deinit();
    }

    var lines = std.mem.tokenizeAny(u8, std.mem.trim(u8, input, " \n\r"), "\n");
    while (lines.next()) |line| {
        var parts = std.mem.splitSequence(u8, std.mem.trim(u8, line, " \r\n"), "contain");
        const container_raw = std.mem.trim(u8, parts.next() orelse continue, " ");
        const contents_raw = std.mem.trim(u8, parts.next() orelse continue, " ");

        // Extract container bag name (remove " bags")
        const container_name = if (std.mem.endsWith(u8, container_raw, " bags"))
            container_raw[0 .. container_raw.len - " bags".len]
        else if (std.mem.endsWith(u8, container_raw, " bag"))
            container_raw[0 .. container_raw.len - " bag".len]
        else
            container_raw;
        const trimmed_container = std.mem.trim(u8, container_name, " ");

        var contents = std.StringHashMap(usize).init(allocator);
        errdefer {
            // Clean up inner map keys on error
            var inner_iter = contents.iterator();
            while (inner_iter.next()) |inner_entry| {
                allocator.free(inner_entry.key_ptr.*);
            }
            contents.deinit();
        }

        if (std.mem.eql(u8, contents_raw, "no other bags.") or
            std.mem.eql(u8, contents_raw, "no other bags") or
            std.mem.eql(u8, contents_raw, "no other bag."))
        {
            try map.put(try allocator.dupe(u8, trimmed_container), contents);
            continue;
        }

        var bags = std.mem.splitSequence(u8, contents_raw, ",");
        while (bags.next()) |bag_spec| {
            const trimmed = std.mem.trim(u8, bag_spec, " \r\n.");
            if (trimmed.len == 0) continue;

            var words = std.mem.tokenizeAny(u8, trimmed, " ");
            const count_str = words.next() orelse continue;
            const count = std.fmt.parseInt(usize, count_str, 10) catch continue;

            const color1 = words.next() orelse continue;
            const color2 = words.next() orelse continue;
            const bag_name = try std.fmt.allocPrint(allocator, "{s} {s}", .{ color1, color2 });
            errdefer allocator.free(bag_name);
            try contents.put(bag_name, count);
        }

        try map.put(try allocator.dupe(u8, trimmed_container), contents);
    }

    return map;
}

fn isContainShinyGold(map: *const Map, color: []const u8) bool {
    const contents = map.get(color) orelse return false;
    if (contents.contains("shiny gold")) return true;
    
    var iter = contents.iterator();
    while (iter.next()) |entry| {
        if (isContainShinyGold(map, entry.key_ptr.*)) return true;
    }
    return false;
}

fn countBags(map: *const Map, color: []const u8) usize {
    const contents = map.get(color) orelse return 0;
    if (contents.count() == 0) return 0;

    var total: usize = 0;
    var iter = contents.iterator();
    while (iter.next()) |entry| {
        const inner_count = countBags(map, entry.key_ptr.*);
        total += entry.value_ptr.* * (inner_count + 1);
    }
    return total;
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !usize {
    var map = try parseInput(allocator, input);
    defer {
        var iter = map.iterator();
        while (iter.next()) |entry| {
            // Free all keys in inner maps
            var inner_iter = entry.value_ptr.*.iterator();
            while (inner_iter.next()) |inner_entry| {
                allocator.free(inner_entry.key_ptr.*);
            }
            entry.value_ptr.deinit();
            allocator.free(entry.key_ptr.*);
        }
        map.deinit();
    }

    var count: usize = 0;
    var iter = map.iterator();
    while (iter.next()) |entry| {
        if (!std.mem.eql(u8, entry.key_ptr.*, "shiny gold") and isContainShinyGold(&map, entry.key_ptr.*)) {
            count += 1;
        }
    }
    return count;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !usize {
    var map = try parseInput(allocator, input);
    defer {
        var iter = map.iterator();
        while (iter.next()) |entry| {
            // Free all keys in inner maps
            var inner_iter = entry.value_ptr.*.iterator();
            while (inner_iter.next()) |inner_entry| {
                allocator.free(inner_entry.key_ptr.*);
            }
            entry.value_ptr.deinit();
            allocator.free(entry.key_ptr.*);
        }
        map.deinit();
    }

    return countBags(&map, "shiny gold");
}

// Public interfaces
pub fn partOne(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .usize = try part1(allocator, input) };
}

pub fn partTwo(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .usize = try part2(allocator, input) };
}

// Unit tests
test "day 07 example" {
    const allocator = std.testing.allocator;
    const input = try utils.readExample(allocator, 7);
    defer allocator.free(input);

    const p1 = try part1(allocator, input);
    try std.testing.expectEqual(@as(usize, 4), p1);

    const p2 = try part2(allocator, input);
    try std.testing.expectEqual(@as(usize, 32), p2);
}