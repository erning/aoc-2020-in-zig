# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build the project
zig build

# Run the executable
zig build run

# Run with specific day and options
zig build run -- 1 --example --time
zig build run -- 1 2 3 --time
```

## Project Architecture

This is an **Advent of Code 2020** solution repository implemented in **Zig 0.14+**. The project structure follows a standardized pattern for AoC solutions:

- **`src/`** - Source code directory
  - `main.zig` - Entry point that orchestrates running all/parts of puzzles
  - `aoc.zig` - Contains `Solution` type with `i32|usize|string` union
  - `utils.zig` - Common utilities: file loading (`readInput`, `readExample`), string splitting, mapping functions
  - `day01.zig` through `day25.zig` - Solution implementations (7 completed: days 1-7)

- **`inputs/`** - Input files for each day
  - `{day:02}-{example|input}.txt` format (e.g., 01-example.txt, 01-input.txt)

- **`build.zig`** - Standard zig build configuration

## Day Template

Each `dayXX.zig` follows this pattern:
- `pub fn partOne(allocator, input) -> Solution` - Public interface function
- `pub fn partTwo(allocator, input) -> Solution` - Public interface function
- Internal `part1/part2` functions for actual implementation
- Unit tests with assertions against day-specific examples

## Common Operations

```bash
# Run all days
zig build run

# Run specific day(s)
zig build run -- 3 5

# Run with example input
zig build run -- 1 --example

# Show execution timing
zig build run -- 1 --time

# Run tests for a specific day
zig test src/day01.zig

# Check all days compile
zig build
```

## Key Libraries Used

- Standard library only (`std`)
- Memory: `std.heap.GeneralPurposeAllocator` for allocator creation
- CLI: `std.process.argsWithAllocator` for argument parsing
- Time: `std.time.Timer` for performance measurement
- File: `utils.readAsString(allocator, day, type)` from utils.zig for input loading