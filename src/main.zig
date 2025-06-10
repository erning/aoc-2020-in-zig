//! src/main.zig
const std = @import("std");
const aoc = @import("aoc.zig");

// Define a type for the solver functions.
// It's a function pointer that takes an allocator and a string slice (input)
// and returns a `Solution` union, which can hold different result types.
const SolverFn = *const fn (allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution;

// A struct to hold the puzzle details.
const Puzzle = struct {
    title: []const u8,
    part1: SolverFn,
    part2: SolverFn,
};

// An array of titles for each puzzle.
const puzzle_titles = [_][]const u8{
    "Historian Hysteria",
    // "Password Philosophy",
    // "Toboggan Trajectory",
    // "Passport Processing",
    // "Binary Boarding",
    // "Custom Customs",
    // "Handy Haversacks",
    // "Handheld Halting",
    // "Encoding Error",
    // "Adapter Array",
    // "Seating System",
    // "Rain Risk",
    // "Shuttle Search",
    // "Docking Data",
    // "Rambunctious Recitation",
    // "Ticket Translation",
    // "Conway Cubes",
    // "Operation Order",
    // "Monster Messages",
};

// Generate the puzzles array at compile-time to avoid repetition.
const puzzles = blk: {
    var puzzles_array: [puzzle_titles.len]Puzzle = undefined;

    // The day modules are now imported here, inside a temporary struct,
    // to break the circular dependency that would otherwise occur.
    const DayModules = struct {
        const day01 = @import("day01.zig");
        // const day02 = @import("day02.zig");
        // const day03 = @import("day03.zig");
        // const day04 = @import("day04.zig");
        // const day05 = @import("day05.zig");
        // const day06 = @import("day06.zig");
        // const day07 = @import("day07.zig");
        // const day08 = @import("day08.zig");
        // const day09 = @import("day09.zig");
        // const day10 = @import("day10.zig");
        // const day11 = @import("day11.zig");
        // const day12 = @import("day12.zig");
        // const day13 = @import("day13.zig");
        // const day14 = @import("day14.zig");
        // const day15 = @import("day15.zig");
        // const day16 = @import("day16.zig");
        // const day17 = @import("day17.zig");
        // const day18 = @import("day18.zig");
        // const day19 = @import("day19.zig");
    };

    for (puzzle_titles, 0..) |title, i| {
        const day_num = i + 1;
        // Generate the field name for the day module (e.g., "day01", "day02").
        const day_field_name = std.fmt.comptimePrint("day{d:0>2}", .{day_num});
        // Get the module for the specific day using the generated field name.
        const day_module = @field(DayModules, day_field_name);

        puzzles_array[i] = .{
            .title = title,
            .part1 = &day_module.partOne,
            .part2 = &day_module.partTwo,
        };
    }

    break :blk puzzles_array;
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
        const input = aoc.readAsString(allocator, filename) catch |err| {
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
