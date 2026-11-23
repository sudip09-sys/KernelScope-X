# Memory Intelligence Lab — Week 9 Demonstration

**Project:** KernelScope X | **Owner:** SAH SUDIP | **Student ID:** 202637610

## Launch

- [Main website](https://sudip09-sys.github.io/KernelScope-X/)
- [Memory Intelligence Lab](https://sudip09-sys.github.io/KernelScope-X/memory-lab.html)
- Source: `memory-lab.html`, `memory-lab.css`, `memory-lab.js`

The memory laboratory is a **browser-based educational simulator**. It does not read Windows page tables, access kernel RAM, or allocate real physical frames. Actual host CPU/RAM/process telemetry is collected separately by the native C++/Qt app.

## 1. Paging and address translation

- Page size: **1024 B**
- Page table (valid entries): page 0 → frame 5; page 1 → frame 9; page 2 → frame 1; page 3 → frame 12.
- Page number = floor(logical address / 1024)
- Offset = logical address mod 1024
- Physical address = mapped frame × 1024 + offset

| Logical | Page | Offset | Frame | Physical |
|---:|---:|---:|---:|---:|
| 0 | 0 | 0 | 5 | 5120 |
| 500 | 0 | 500 | 5 | 5620 |
| 1024 | 1 | 0 | 9 | 9216 |
| 1500 | 1 | 476 | 9 | 9692 |
| 2048 | 2 | 0 | 1 | 1024 |
| 3000 | 2 | 952 | 1 | 1976 |
| 4095 | 3 | 1023 | 12 | 13311 |
| 5000 | 4 | 904 | no entry | invalid |

A missing page-table entry **cannot be translated within the given mapping**. On a real OS, a missing/non-present mapping could trigger a page fault and potentially be resolved; an invalid access may instead be rejected. This example intentionally has no valid page-4 entry.

### TLB

The demonstration uses a **3-entry, fully associative LRU cache**. Hits promote entries to most recently used; misses consult the example page table. An unmapped page does not enter the cache. Hit/miss counters represent the simulated access trace, not performance measurements from the host CPU.

## 2. Contiguous memory allocation

Initial holes (KB): **100, 500, 200, 300, 600**

Requests in order (KB): **P1 = 212, P2 = 417, P3 = 112, P4 = 426**

| Process | First Fit | Best Fit | Worst Fit |
|---|---|---|---|
| P1 (212) | H2 500 → 288 left | H4 300 → 88 left | H5 600 → 388 left |
| P2 (417) | H5 600 → 183 left | H2 500 → 83 left | H2 500 → 83 left |
| P3 (112) | H2 288 → 176 left | H3 200 → 88 left | H5 388 → 276 left |
| P4 (426) | cannot place | H5 600 → 174 left | cannot place |

Outcomes:
- First Fit: 3/4 allocated, 959 KB total free; largest individual hole 300 KB.
- Best Fit: 4/4 allocated, 533 KB total free; largest individual hole 174 KB.
- Worst Fit: 3/4 allocated, 959 KB total free; largest individual hole 300 KB.

The lab labels **free space outside the largest hole** as an explanatory fragmentation indicator; it is not a universal or standard numerical fragmentation measure. Memory placement depends on request order and hole sizes. No deallocations, compaction, or coalescing are modeled.

## Demonstration script for professor

1. Open Memory Lab. Translate address 1500 and explain page 1, offset 476, frame 9, resulting in 9692.
2. Translate address 5000 to demonstrate an unmapped page.
3. Clear TLB and run the sample trace to show hits, misses and LRU eviction.
4. Run memory allocation **one process at a time** and compare where each strategy places the request.
5. Show why First Fit fails P4 despite 959 KB free — no single hole is at least 426 KB.
6. Modify hole sizes and show that no allocation policy is universally optimal.

## Validation checklist

- [ ] On the public website, verify the eight lecture addresses against the table.
- [ ] Enter blank, negative, fractional and non-numeric addresses; verify a clear validation message.
- [ ] Run the TLB trace, clear it, and test a repeated page for a hit.
- [ ] Run all four memory requests and verify the outcomes above.
- [ ] Reset, step individually, change hole sizes and verify allocations and totals.
- [ ] Check responsive layout on mobile and desktop.
- [ ] Document actual screenshots before claiming full browser acceptance testing.

GitHub-hosted static source has been syntax-checked, but interactive browser testing must be done on the deployed site.