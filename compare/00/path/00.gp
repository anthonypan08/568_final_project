set term png size 900,900
set output "00.png"
set size ratio -1
set xrange [-303:320]
set yrange [-81:542]
set xlabel "x [m]"
set ylabel "z [m]"
plot "00.txt" using 1:2 lc rgb "#FF0000" title 'Ground Truth' w lines,"00.txt" using 3:4 lc rgb "#a82296" title 'Original SuMa++' w lines,"< head -1 00.txt" using 1:2 lc rgb "#000000" pt 4 ps 1 lw 2 title 'Sequence Start' w points, \
"00_c.txt" using 3:4 lc rgb "#df8c932" title 'SuMa++ w/ correntropy' w lines, \
"00_l.txt" using 3:4 lc rgb "#0000FF" title 'SuMa++ w/ heuristic idea' w lines, \
"00_b.txt" using 3:4 lc rgb "#27ad81" title 'SuMa++ w/ both ideas' w lines

