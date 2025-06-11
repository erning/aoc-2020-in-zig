const std = @import("std");
const aoc = @import("./aoc.zig");
const utils = @import("./utils.zig");

const day01 = @import("./day01.zig");
const day02 = @import("./day02.zig");

const SolverFn = *const fn (allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution;

const Puzzle = struct { title: []const u8, part1: SolverFn, part2: SolverFn };
const puzzles = [_]Puzzle{
    .{ .part1 = &day01.partOne, .part2 = &day01.partTwo, .title = "Historian Hysteria" },
    .{ .part1 = &day02.partOne, .part2 = &day02.partTwo, .title = "Password Philosophy" },
};

pub fn main() !void {
    // Set up the allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Process command line arguments
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.next(); // Skip the program name

    var use_example = false;
    var show_time = false;
    var days_to_run = std.ArrayList(usize).init(allocator);
    defer days_to_run.deinit();

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--example")) {
            use_example = true;
        } else if (std.mem.eql(u8, arg, "--time")) {
            show_time = true;
        } else if (std.fmt.parseInt(usize, arg, 10)) |day| {
            try days_to_run.append(day);
        } else |_| {
            // Ignore other arguments
        }
    }

    // If no days are specified, run all of them.
    if (days_to_run.items.len == 0) {
        try days_to_run.ensureTotalCapacity(puzzles.len);
        for (0..puzzles.len) |i| {
            days_to_run.appendAssumeCapacity(i + 1);
        }
    }

    // Main loop to run the selected puzzles
    for (days_to_run.items) |day| {
        if (day == 0 or day > puzzles.len) {
            std.log.warn("Day {} is not available. Skipping.", .{day});
            continue;
        }

        const puzzle = puzzles[day - 1];
        const filename = try std.fmt.allocPrint(allocator, "inputs/{d:0>2}-{s}.txt", .{ day, "input" });
        defer allocator.free(filename);
        const input = utils.readAsString(allocator, filename) catch |err| {
            std.log.err("Failed to read input for day {}: {s}", .{ day, @errorName(err) });
            continue;
        };
        defer allocator.free(input);

        std.debug.print("--- Day {d}: {s} ---\n", .{ day, puzzle.title });
        var timer = if (show_time) try std.time.Timer.start() else null;

        // part 1
        const part1_result = puzzle.part1(allocator, input) catch |err| {
            std.log.err("Part one for day {} failed: {s}", .{ day, @errorName(err) });
            continue;
        };
        const t1 = if (timer) |*t| t.read() else 0;
        std.debug.print("Part One: {}\n", .{part1_result});

        // part 2
        const part2_result = puzzle.part2(allocator, input) catch |err| {
            std.log.err("Part two for day {} failed: {s}", .{ day, @errorName(err) });
            continue;
        };
        const t2 = if (timer) |*t| t.read() else 0;
        std.debug.print("Part Two: {}\n", .{part2_result});

        //
        if (timer) |_| {
            const d1_ms = @as(f64, @floatFromInt(t1)) / std.time.ns_per_ms;
            const d2_ms = @as(f64, @floatFromInt(t2 - t1)) / std.time.ns_per_ms;
            std.debug.print("Duration: (Part 1: {d:.3}ms, Part 2: {d:.3}ms)\n", .{ d1_ms, d2_ms });
        }
        std.debug.print("\n", .{});
    }
}
