# ECE425: mp2 README

**This document, `README.md`, forms the specification for the machine problem. For a more comprehensive summary, see [GUIDE.md](./GUIDE.md).**

## Custom Design RISC-V Processor Datapath Layout

Your design should be in a new virtuoso library: `ece425mp2_<netid>`. For example, `ece425mp2_zaizhou3`.

You will design the schematic and layout of the datapath of a bit-sliced RISC-V32I compliant single-cycle processor
(with the exception of `FENCE*`, `ECALL`, `EBREAK`, and `CSRR*` instructions).

The entire design is provided to you in SystemVerilog. Use it as a reference.
You do not need to create the schematic or layout for the control unit.

You can modify the provided code to add more signals that are connected between your datapath and control unit.
Any logic added to the controller may not be something that can be bitsliced.

Your top level design cell should be named `datapath`.

You are allowed to use up to (and including) `metal6`.

The datapath should be 32 identical bitslice instances stitched together.

The bitsliced inputs to your datapath are `dmem_rdata` and `imm`.
The bitsliced outputs from your datapath are `dmem_addr`, `dmem_wdata`, and `imem_addr`.
All of these should be on either the leftmost or the rightmost edge of your bitslice.
All signals from and to the controller should be wired the top edge of your datapath.

## Grading

### Submission

Submit your entire design library as a tar file. The design library is the `<ece425_folder>/ece425mp2_<netid>` folder.
Because you might have used and modified your mp1 library, you should include your up-to-date mp1 library as a tar file as well,
the `<ece425_folder>/ece425mp1_<netid>` folder.

Include the drc and lvs report summary for the datapath. They can be found in `<ece425_folder>/drc/datapath.drc.summary`
and `<ece425_folder>/lvs/datapath.lvs.report`.

Include clear and detailed screenshots of all your schematics,
and include the extracted Verilog from your schematic.

Include the `sim/hdl` folder, whether you have modified it or not.

Include clear and detailed screenshots of the layout of every cell in your design.
Include two rulers in the screenshot in the datapath that bounds your entire design for us to see your area.

Simulate your design with the the provided testcode on your extracted netlist.
Include a screenshot of the waveform window in verdi showing all the register values.

Submit a zip file to canvas with the following structure:

```
submission.zip
├── ihnl
│   ├── cds0
│   │   └──netlist
│   ├── cds1
│   │   └──netlist
│   └── ...
├── schematics
│   ├── datapath.png
│   ├── bitslice.png
│   └── ...
├── layout
│   ├── datapath.png
│   ├── bitslice.png
│   └── ...
├── hdl
│   ├── control.sv
│   └── cpu.sv
├── datapath.drc.summary
├── datapath.lvs.report
├── verdi.png
├── ece425mp1_<netid>.tar
└── ece425mp2_<netid>.tar
```

### Rubric

This assignment is graded out of 10 points and floored at 0 points.

Each mistake/error will get these points deducted:

| Metric                     | Points    |
|---|---|
| Incorrect schematic        | up to -10 |
| Failing DRC / LVS          | up to -10 |
| Layout style               | up to -10 |

Although this rubric looks strict, we will grade fairly and generously.

Partial credit is awarded. If you find that you are unable to finish,
do as much as you can and focus on making parts of the CPU bitsliced and connected together properly.
For example, a fully connected bitsliced ALU or shifter without a comparison unit will be awarded partial credit.

Style points will not be deducted for most submissions.
It is a catch all clause to penalize designs that are not bitsliced,
design with excess wasted area, bitslicable logic added to controller, etc.

Extra credit is awarded based on area:

| Place            | Points |
|---|---|
| 1st              | +3 |
| 2nd-5th          | +2 |
| 6th-15th         | +1 |
| 16th-last        | +0 |

Designs that do not receive full credit will not be eligible for the area competition.
Designs that exploit the DRC checker bug will also be disqualified.
