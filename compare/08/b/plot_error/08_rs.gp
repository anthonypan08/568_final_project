set term png size 500,250 font "Helvetica" 11
set output "08_rs.png"
set size ratio 0.5
set yrange [0:*]
set xlabel "Speed [km/h]"
set ylabel "Rotation Error [deg/m]"
plot "08_rs.txt" using ($1*3.6):($2*57.3) title 'Rotation Error' lc rgb "#0000FF" pt 4 w linespoints
