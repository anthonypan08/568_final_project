set term png size 900,900
set output "07.png"
set size ratio -1
set xrange [-206:23]
set yrange [-99:131]
set xlabel "x [m]"
set ylabel "z [m]"
plot "07.txt" using 1:2 lc rgb "#FF0000" title 'Ground Truth' w lines,"07.txt" using 3:4 lc rgb "#0000FF" title 'Visual Odometry' w lines,"< head -1 07.txt" using 1:2 lc rgb "#000000" pt 4 ps 1 lw 2 title 'Sequence Start' w points
