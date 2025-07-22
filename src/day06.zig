const std = @import("std");
const aoc = @import("./aoc.zig");
const utils = @import("./utils.zig");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

fn part1(allocator: Allocator, input: []const u8) !usize {
    _ = allocator;
    var sum: usize = 0;
    
    var groups_it = std.mem.splitSequence(u8, std.mem.trim(u8, input, &std.ascii.whitespace), "\n\n");
    while (groups_it.next()) |group_text| {
        var answers = [_]bool{false} ** 26;
        
        var person_it = std.mem.tokenizeAny(u8, std.mem.trim(u8, group_text, &std.ascii.whitespace), "\n ");
        while (person_it.next()) |person| {
            for (person) |ch| {
                if (ch >= 'a' and ch <= 'z') {
                    answers[ch - 'a'] = true;
                }
            }
        }
        
        var count: usize = 0;
        for (answers) |answered| {
            if (answered) count += 1;
        }
        sum += count;
    }
    
    return sum;
}

fn part2(allocator: Allocator, input: []const u8) !usize {
    _ = allocator;
    var sum: usize = 0;
    
    var groups_it = std.mem.splitSequence(u8, std.mem.trim(u8, input, &std.ascii.whitespace), "\n\n");
    while (groups_it.next()) |group_text| {
        var answers = [_]u16{0} ** 26;
        var people_in_group: usize = 0;
        
        var person_it = std.mem.tokenizeAny(u8, std.mem.trim(u8, group_text, &std.ascii.whitespace), "\n ");
        while (person_it.next()) |person| {
            people_in_group += 1;
            for (person) |ch| {
                if (ch >= 'a' and ch <= 'z') {
                    answers[ch - 'a'] += 1;
                }
            }
        }
        
        var count: usize = 0;
        for (answers) |answer_count| {
            if (answer_count == people_in_group) count += 1;
        }
        sum += count;
    }
    
    return sum;
}

pub fn partOne(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .usize = try part1(allocator, input) };
}

pub fn partTwo(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .usize = try part2(allocator, input) };
}

test "day 06 example" {
    const allocator = std.testing.allocator;
    const input = try utils.readExample(allocator, 6);
    defer allocator.free(input);

    const p1 = try part1(allocator, input);
    try std.testing.expectEqual(@as(usize, 11), p1);

    const p2 = try part2(allocator, input);
    try std.testing.expectEqual(@as(usize, 6), p2);
}