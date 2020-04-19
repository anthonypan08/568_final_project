set term png size 500,250 font "Helvetica" 11
set output "04_tl.png"
set size ratio 0.5
set yrange [0:*]
set xlabel "Path Length [m]"
set ylabel "Translation Error [%]"
plot "04_tl.txt" using 1:($2*100) title 'Translation Error' lc rgb "#0000FF" pt 4 w linespoints
