# ECE425: mp1 README

**This document, `README.md`, forms the specification for the machine problem. For a more comprehensive summary, see [GUIDE.md](./GUIDE.md).**

## Standard Cells

These deliverable are useful in MP2, and required in MP3.

Your design should be in a new virtuoso library: `ece425mp1_<netid>`. Say for example, `ece425mp1_zaizhou3`.

Your cell should be laid out so that they can be fitted in a row:
- All cell should be of the same height.
- wells across cells should be of the same height and extend left and right to at least the same extent as power rails.
- Both vdd and vss rail should be 200nm wide.
- At least ceil((min_spacing_between_metal_2) / 2) amount of white space
  on left and right side of the cell on metal 1 and 2 excluding power rail.

Your cell should be area efficient:
- Should be reasonably compact, ideally the smallest allowed by DRC (white space due to cell height is allowed).
- Merge source and/or drain of transistors in series as much as possible.
  - Some will share a terminal, where it is source of one and drain of the other.
  - Some will not have the middle terminal at all, and there are two or more gates over a single active area.
  - Some will share a terminal, where it is the source/drain of both.

You are allowed to use up to metal 2 in your design. All your pins should be accessible on metal 2.

You should include well tap inside your cells.

All your cells should have a minimum pull up and pull down power equivalent to a w=90nm l=50nm NMOS.
All gate should have length of 50nm. Assume NMOS is twice as conductive as PMOS.

All your combinational cells need to be CMOS.

For all input, no complementary of them should be used as input
i.e. if you need complementaries, use inverters inside your cell.

You are required to implement the following standard cells:

| Name      | Description | Remarks |
|---|---|---|
|`AND2`     | `Z = A & B`                       | |
|`AOI21`    | `Z = ~((A & B) \| C)`             | |
|`BUF`      | `Z = A`                           | two `INV` chained |
|`DFF`      | d-flip-flop                       | See guide |
|`LATCH`    | d-latch                           | See guide |
|`INV`      | `Z = ~A`                          | |
|`MUX2`     | `Z = (~S0 & A) \| (S0 & B)`       | |
|`NAND2`    | `Z = ~(A & B)`                    | |
|`NOR2`     | `Z= ~(A \| B)`                    | |
|`OAI21`    | `Z = ~((A \| B) & C)`             | |
|`OR2`      | `Z = A \| B`                      | |
|`XNOR2`    | `Z = ~(A ^ B)`                    | 10 transistors |
|`XOR2`     | `Z = A ^ B`                       | 10 transistors |

The following cells are extra credit if you implement them (very useful in MP2 and MP3)
(I am too lazy to write all descriptions so please extrapolate them):

| Name      | Description |
|---|---|
|`A2DFF`    | `DFF` with `AND2` on input        |
|`AND3`     | `AND2` but 3 input                |
|`AND4`     |                                   |
|`AO21`     | `Z = (A & B) \| C`                |
|`AOI22`    | `Z = ~((A & B) \| (C & D))`       |
|`AOI33`    |                                   |
|`AOI211`   | `Z = ~((A & B) \| C \| D)`        |
|`AOI221`   |                                   |
|`AOI222`   |                                   |
|`DFFRS`    | `DFF` with async reset and set    |
|`DFFR`     |                                   |
|`DFFS`     |                                   |
|`FA`       | full adder                        |
|`FILL`     | cell with nothing but the wells   |
|`HA`       | half adder                        |
|`M2DFF`    | `DFF` with `MUX2` on input        |
|`LOGIC0`   | tied to logic 0                   |
|`LOGIC1`   | tied to logic 1                   |
|`MUX3`     |                                   |
|`MUX4`     |                                   |
|`MUX5`     |                                   |
|`NAND3`    |                                   |
|`NAND4`    |                                   |
|`NOR3`     |                                   |
|`NOR4`     |                                   |
|`OA21`     | `Z = (A \| B) & C`                |
|`OAI22`    |                                   |
|`OAI33`    |                                   |
|`OAI211`   |                                   |
|`OAI221`   |                                   |
|`OAI222`   |                                   |
|`OR3`      |                                   |
|`OR4`      |                                   |
|`TBUF`     | tri-state buffer                  |
|`XNOR3`    |                                   |
|`XNOR4`    |                                   |
|`XOR3`     |                                   |
|`XOR4`     |                                   |

You can also come up with some other interesting cells to be implemented. Those that are non trivial would also receive points.

## Rise/Fall Time Simulation

For your NAND2 cell, using analog simulation, find out:
- Fall time for your cell when:
  - Both A and B rise from 0 to 1
  - Only A rises while B stays 1
  - Only B rises while A stays 1
- Rise time for your cell when:
  - Both A and B fall from 1 to 0
  - Only A falls while B stays 1
  - Only B falls while A stays 1

Use 5ps as the rise and fall time for both input. Use 1V as VDD.

Rise time is defined as the time it takes from when the input reaches 0.3\*VDD (for falling input) or 0.7\*VDD (for rising input),
until the output reaches 0.7\*VDD.
Fall time is the reverse.

## Grading

### Submission

You will need to take clean and detailed screenshot of both the schematic and the layout of all the cell you implemented.
For the layout screenshot, include all layers and expand all hierarchy (`Shift+F`).
Within the screenshot of the layout, include a measurement ruler so that the grader can gauge how big the entire design is.

You should also include the drc and lvs report summary for each of your cells. They can be found in `<ece425_folder>/drc/<cell>.drc.summary`
and `<ece425_folder>/lvs/<cell>.lvs.report`.

Include the screenshots of your analog simulation in a folder named `sim`. The screenshot should be clean and include the axis.
Include a txt file briefly explaining the observation.

Lastly, include your entire design library as a tar file. The design library is the `<ece425_folder>/ece425mp1_<netid>` folder.

Submit a zip file to canvas with the following structure:

```
submission.zip
├── sim
│   ├── NAND2.rise.AB.png
│   ├── NAND2.rise.A.png
│   ├── NAND2.rise.B.png
│   ├── NAND2.fall.AB.png
│   ├── NAND2.fall.A.png
│   ├── NAND2.fall.B.png
│   └── what.txt
├── AND2
│   ├── AND2.drc.summary
│   ├── AND2.lvs.report
│   ├── AND2.schematic.png
│   └── AND2.layout.png
├── AOI21
│   └── ...
├── ...
└── ece425mp1_<netid>.tar
```

### Rubric

This assignment is out of 100 points.

For each of the required 13 cells, each cell is worth 7 points.
Each mistake/error will get these points deduction:

| Metric                   | Points |
|---|---|
| Schematic Incorrectness  | -3     |
| Layout (bad) Style       | -4     |
| Layout Incompactness     | -4     |
| Failing DRC              | -5     |
| Failing LVS              | -5     |

Points for each cell is floored at 0.

Extra credit cells are 1 point each.
You have to fulfill all the above requirements to get point for each extra credit cell.

Simulation of NAND2 is graded on completion, 1 point for each simulation, and 3 points for the explanation. 
