const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const vulkan_headers = b.dependency("vulkan_headers", .{}).path("include");

    const vma = b.addStaticLibrary(.{
        .name = "PlugInZ.VMA",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(vma);

    vma.addIncludePath(vulkan_headers);
    vma.addIncludePath(b.path(vma_include_dir));
    vma.linkLibC();
    vma.linkLibCpp();
    vma.addCSourceFile(.{ .file = b.path(vma_src_dir ++ "vk_mem_alloc.cpp"), .flags = &.{""} });

    const volk = b.addStaticLibrary(.{
        .name = "PlugInZ.Volk",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(volk);

    volk.addIncludePath(vulkan_headers);
    volk.addIncludePath(b.path(volk_include_dir));
    volk.linkLibC();
    volk.addCSourceFile(.{ .file = b.path(volk_src_dir ++ "volk.c"), .flags = &.{""} });

    const module = b.addModule("vulkan", .{
        .root_source_file = b.path("src/root.zig"),
    });

    module.addIncludePath(vulkan_headers);
    module.addIncludePath(b.path(vma_include_dir));
    module.addIncludePath(b.path(volk_include_dir));

    module.linkLibrary(vma);
    module.linkLibrary(volk);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

const vma_include_dir = "libs/vma/include";
const vma_src_dir = "libs/vma/src/";

const volk_include_dir = "libs/volk/include";
const volk_src_dir = "libs/volk/src/";
