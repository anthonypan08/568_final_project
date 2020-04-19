set term png size 500,250 font "Helvetica" 11
set output "03_tl.png"
set size ratio 0.5
set yrange [0:*]
set xlabel "Path Length [m]"
set ylabel "Translation Error [%]"
set key top
plot "03_tl.txt" using 1:($2*57.3) title 'Original SuMa++' lc rgb "#e35933" pt 4 w linespoints, \
"c.txt" using 1:($2*57.3) title 'SuMa++ w/ correntropy' lc rgb "#df8c932" pt 4 w linespoints, \
"l.txt" using 1:($2*57.3) title 'SuMa++ w/ heuristic idea' lc rgb "#0000FF" pt 4 w linespoints, \
"b.txt" using 1:($2*57.3) title 'SuMa++ w/ both ideas ' lc rgb "#27ad81" pt 4 w linespoints
