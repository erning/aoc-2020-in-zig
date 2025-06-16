const std = @import("std");
const aoc = @import("./aoc.zig");
const utils = @import("./utils.zig");

const Allocator = std.mem.Allocator;
const StringHashMap = std.StringHashMap;
const ArrayList = std.ArrayList;

/// A passport is represented as a HashMap of string slices.
const Passport = StringHashMap([]const u8);

/// Parses the multi-line input string into a list of passports.
/// Each passport is a HashMap where keys are field names (e.g., "byr")
/// and values are the corresponding data (e.g., "1980").
///
/// - `allocator`: The memory allocator to use for creating the list and hashmaps.
/// - `input`: The raw input string containing passport data.
/// Returns an ArrayList of Passports, or an error if memory allocation fails.
pub fn parseInput(allocator: Allocator, input: []const u8) !ArrayList(Passport) {
    var passports = ArrayList(Passport).init(allocator);

    // Passports are separated by blank lines.
    var passport_it = std.mem.splitScalar(u8, input, '\n');
    var current_passport = Passport.init(allocator);
    errdefer {
        // Ensure we clean up all allocated memory on error.
        for (passports.items) |*p| p.deinit();
        passports.deinit();
        current_passport.deinit();
    }

    var fields_in_passport = false;
    while (passport_it.next()) |line| {
        const trimmed_line = std.mem.trim(u8, line, &std.ascii.whitespace);

        if (trimmed_line.len == 0) {
            // Empty line signifies the end of a passport entry.
            // If we have collected fields, add the passport to our list.
            if (fields_in_passport) {
                try passports.append(current_passport);
                current_passport = Passport.init(allocator); // Reset for the next one.
                fields_in_passport = false;
            }
            continue;
        }

        // Tokenize the line by spaces to get key:value pairs.
        var field_it = std.mem.tokenizeAny(u8, trimmed_line, " \n");
        while (field_it.next()) |field| {
            // Split "key:value" into "key" and "value".
            var pair_it = std.mem.splitScalar(u8, field, ':');
            const key = pair_it.next() orelse continue;
            const value = pair_it.next() orelse continue;

            // Store the key-value pair in the current passport's map.
            try current_passport.put(key, value);
            fields_in_passport = true;
        }
    }

    // Add the last passport if the file doesn't end with a blank line.
    if (fields_in_passport) {
        try passports.append(current_passport);
    } else {
        // If the last passport was empty, deinitialize it.
        current_passport.deinit();
    }

    return passports;
}

// All possible passport fields. "cid" is optional.
const FIELDS = [_][]const u8{ "byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid" };

/// Checks if a passport has all the required fields.
/// The only optional field is "cid".
fn hasRequiredFields(passport: *const Passport) bool {
    // Iterate through all fields except the last one ("cid").
    for (FIELDS[0 .. FIELDS.len - 1]) |field| {
        if (!passport.contains(field)) {
            return false;
        }
    }
    return true;
}

/// Checks if all values in a passport are valid according to the rules.
fn hasValidValues(passport: *const Passport) bool {
    var it = passport.iterator();
    while (it.next()) |entry| {
        const key = entry.key_ptr.*;
        const value = entry.value_ptr.*;
        if (std.mem.eql(u8, key, "byr")) {
            // byr (Birth Year) - four digits; at least 1920 and at most 2002.
            const v = std.fmt.parseInt(usize, value, 10) catch {
                return false;
            };
            if (v < 1920 or v > 2002) {
                return false;
            }
        } else if (std.mem.eql(u8, key, "iyr")) {
            // iyr (Issue Year) - four digits; at least 2010 and at most 2020.
            const v = std.fmt.parseInt(usize, value, 10) catch {
                return false;
            };
            if (v < 2010 or v > 2020) {
                return false;
            }
        } else if (std.mem.eql(u8, key, "eyr")) {
            // eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
            const v = std.fmt.parseInt(usize, value, 10) catch {
                return false;
            };
            if (v < 2020 or v > 2030) {
                return false;
            }
        } else if (std.mem.eql(u8, key, "hgt")) {
            // hgt (Height) - a number followed by either "cm" or "in":
            if (std.mem.endsWith(u8, value, "cm")) {
                // If cm, the number must be at least 150 and at most 193.
                const v = std.fmt.parseInt(usize, value[0 .. value.len - 2], 10) catch {
                    return false;
                };
                if (v < 150 or v > 193) {
                    return false;
                }
            } else if (std.mem.endsWith(u8, value, "in")) {
                // If in, the number must be at least 59 and at most 76.
                const v = std.fmt.parseInt(usize, value[0 .. value.len - 2], 10) catch {
                    return false;
                };
                if (v < 59 or v > 76) {
                    return false;
                }
            } else {
                return false;
            }
        } else if (std.mem.eql(u8, key, "hcl")) {
            // hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
            if (value.len != 7 or value[0] != '#') {
                return false;
            }
            for (value[1..]) |char| {
                if (!std.ascii.isHex(char)) {
                    return false;
                }
            }
        } else if (std.mem.eql(u8, key, "ecl")) {
            // ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
            const valid_ecls = [_][]const u8{ "amb", "blu", "brn", "gry", "grn", "hzl", "oth" };
            var found = false;
            for (valid_ecls) |ecl| {
                if (std.mem.eql(u8, value, ecl)) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                return false;
            }
        } else if (std.mem.eql(u8, key, "pid")) {
            // pid (Passport ID) - a nine-digit number, including leading zeroes.
            if (value.len != 9) {
                return false;
            }
            for (value) |char| {
                if (!std.ascii.isDigit(char)) {
                    return false;
                }
            }
        } else if (std.mem.eql(u8, key, "cid")) {
            // cid (Country ID) - ignored, missing or not.
        } else {
            // Unknown field, consider it invalid.
            return false;
        }
    }
    return true;
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !usize {
    var passports = try parseInput(allocator, input);
    defer {
        for (passports.items) |*p| p.deinit();
        passports.deinit();
    }

    var valid_count: usize = 0;
    for (passports.items) |*passport| {
        if (hasRequiredFields(passport)) {
            valid_count += 1;
        }
    }
    return valid_count;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !usize {
    var passports = try parseInput(allocator, input);
    defer {
        for (passports.items) |*p| p.deinit();
        passports.deinit();
    }

    var valid_count: usize = 0;
    for (passports.items) |*passport| {
        if (hasRequiredFields(passport) and hasValidValues(passport)) {
            valid_count += 1;
        }
    }
    return valid_count;
}

//

pub fn partOne(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .usize = try part1(allocator, input) };
}

pub fn partTwo(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .usize = try part2(allocator, input) };
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
        \\iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
    ;

    const p2 = try part2(allocator, input2);
    try std.testing.expectEqual(4, p2);
}
