const std = @import("std");
const aoc = @import("./aoc.zig");
const utils = @import("./utils.zig");

fn part1(allocator: std.mem.Allocator, input: []const u8) !i32 {
    _ = allocator;
    _ = input;
    return 0;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !i32 {
    _ = allocator;
    _ = input;
    return 0;
}

//

pub fn partOne(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .i32 = try part1(allocator, input) };
}

pub fn partTwo(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .i32 = try part2(allocator, input) };
}

// Unit test
test "day 04 example" {
    const allocator = std.testing.allocator;
    const input = try utils.readExample(allocator, 4);
    defer allocator.free(input);

    const p1 = try part1(allocator, input);
    try std.testing.expectEqual(2, p1);

    const input2 =
        \\eyr:1972 cid:100
        \\hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926
        \\
        \\iyr:2019
        \\hcl:#602927 eyr:1967 hgt:170cm
        \\ecl:grn pid:012533040 byr:1946
        \\
        \\hcl:dab227 iyr:2012
        \\ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277
        \\
        \\hgt:59cm ecl:zzz
        \\eyr:2038 hcl:74454a iyr:2023
        \\pid:3556412378 byr:2007
        \\
        \\pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
        \\hcl:#623a2f
        \\
        \\eyr:2029 ecl:blu cid:129 byr:1989
        \\iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm
        \\
        \\hcl:#888785
        \\hgt:164cm byr:2001 iyr:2015 cid:88
        \\pid:545766238 ecl:hzl
        \\eyr:2022
        \\
        \\iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719"
    ;

    const p2 = try part2(allocator, input2);
    try std.testing.expectEqual(4, p2);
}
