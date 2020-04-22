set term png size 900,900
set output "08.png"
set size ratio -1
set xrange [-430:462]
set yrange [-249:643]
set xlabel "x [m]"
set ylabel "z [m]"
plot "o.txt" using 1:2 lc rgb "#FF0000" title 'Ground Truth' w lines,"o.txt" using 3:4 lc rgb "#a82296" title 'Original SuMa++' w lines,"< head -1 o.txt" using 1:2 lc rgb "#000000" pt 4 ps 1 lw 2 title 'Sequence Start' w points, \
"c.txt" using 3:4 lc rgb "#df8c932" title 'SuMa++ w/ correntropy' w lines, \
"l.txt" using 3:4 lc rgb "#0000FF" title 'SuMa++ w/ heuristic idea' w lines, \
"b.txt" using 3:4 lc rgb "#27ad81" title 'SuMa++ w/ both ideas' w lines
