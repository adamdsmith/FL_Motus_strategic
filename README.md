
This repository contains the data and code necessary to reproduce the
figures in the manuscript “Florida’s strategic position for
collaborative automated-telemetry tracking of avian movements across the
Americas” by Lefevre and Smith (in review at the Journal of Fish and
Wildlife Management).

Authors (affiliation):

  - Kara L. Lefevre, Department of Ecology and Environmental Studies,
    Florida Gulf Coast University, Fort Myers, FL 33965
  - Adam D. Smith, U.S. Fish and Wildlife, National Wildlife Refuge
    System, Division of Strategic Resource Management, Inventory and
    Monitoring Branch, South Atlantic-Gulf and Mississippi Basin, 135
    Phoenix Road, Athens, GA 30605

To produce the
    figures:

1.  [Fork](https://help.github.com/en/github/getting-started-with-github/fork-a-repo)
    or
    [download](https://github.com/adamdsmith/FL_Motus_strategic/archive/master.zip)
    this repository
      - If downloading, unzip the `FL_Motus_strategic-master` directory
        to the desired location
2.  Using [RStudio](https://rstudio.com/) with
    [R](https://www.r-project.org/), navigate to the
    `FL_Motus_strategic.Rproj` file and open in RStudio
      - If not using RStudio, skip to the next step.
3.  Open the `*.R` file within the `R` directory associated with the
    figure you wish to recreate.
      - If using the RStudio project, you may simply run the code to
        generate the figures, which are saved in the `Output` directory.
      - If using R outside of the RStudio project, you’ll need to edit
        the code to update any paths and point them to the `Data` and
        `Output` directories within `FL_Motus_strategic-master`.

We’ve included the figures in the `Output` directory.
