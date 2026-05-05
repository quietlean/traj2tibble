# traj2tibble

This is a code snippet for reading output-files from the online version of HYSPLIT into an R-tibble. For some reason the online verison of HYSPLIT bestows you with the weirdest output files. They lack delimiters and don't conform with classical trajectory data structure. I don't know if there's something I miss? Like some kinda reason for the design of these output-files?! Anyways ... Let's explain what this code does in more detail.

## The scope of this code 🍩

This Codes purpose is to read all the output-files you have (from the online version of HYSPLIT) and combine them into a single tibble / dataframe. Before combining them, the structure of the tibbles is changed so it conforms with the  requirements of packages like openair. 

There is a lot of small changes that are beeing made. The biggest change is the recalculation of the time increments which are used to describe the order of the endponits inside of every trajectory. The online version is using a system where it references all time increments to the start time of the very first trajectory. That might sound confusing. Because it is. The normal way of doing it is to simply create the increments in reference to the start of each trajectory. Since that also sounds a lil googoo, all the changes that are beeing made are showen in the tables below. What is also importend to mention is that most functions of openair work with the trajectories even if you dont fix the time-inrements. But some don't like clustering.

## Who is this code usefull to? 🗯️  

This is only going to be of you use to you if you have to use the online version of hysplit and want to use the output for analysis like Receptor modelling or something like that. I build this for my research that was part of my final thesis in university. As I did not have access to a high performance computer I was forced to use the online version of HYSPLIT 🦧 If you have acces to a HPC I would strongly recommend to use that. In which case you dont need this script beacuse you get a nicely formated tibble from HYSPLIT. If you want to use R for data analysis I recommend using _splitR_. 
