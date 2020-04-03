set term png size 500,250 font "Helvetica" 11
set output "00_ts.png"
set size ratio 0.5
set yrange [0:*]
set xlabel "Speed [km/h]"
set ylabel "Translation Error [%]"
plot "00_ts.txt" using ($1*3.6):($2*100) title 'Translation Error' lc rgb "#0000FF" pt 4 w linespoints
