10 x=20:b=0:ox=x:p=0:sc=0:li=3
15 sp=18:ti=0
20 sx=int(rnd(1)*38)+1:sy=2
30 print chr$(147)
40 poke 1024+sy*40+sx,81
45 gosub 500
50 poke 1024+22*40+x,30
60 k=peek(197)
70 if k=10 and x>0 then x=x-1
80 if k=18 and x<39 then x=x+1
90 if k=60 and b=0 then b=21:c=x
100 poke 1024+22*40+ox,32
110 poke 1024+22*40+x,30
120 ox=x
130 if p>0 then poke 1024+p*40+c,32
140 if b=0 then 190
150 b=b-1
160 if b=sy and c=sx then 220
170 if b<1 then b=0:p=0:goto 190
180 poke 1024+b*40+c,93:p=b
190 ti=ti+1:if ti<sp then 60
200 ti=0:poke 1024+sy*40+sx,32:sy=sy+1
205 if sy>=21 then 300
210 poke 1024+sy*40+sx,81
215 if b=sy and c=sx then 220
217 goto 60
220 poke 1024+sy*40+sx,42
225 for d=1 to 40:next
230 poke 1024+sy*40+sx,43
235 for d=1 to 40:next
240 poke 1024+sy*40+sx,32
245 sc=sc+1
250 if sp>6 and sc/3=int(sc/3) then sp=sp-2
255 b=0:p=0:gosub 500
260 sx=int(rnd(1)*38)+1:sy=2:ti=0
265 poke 1024+sy*40+sx,81
270 goto 60
300 li=li-1:b=0:p=0:gosub 500
310 if li=0 then 340
320 sx=int(rnd(1)*38)+1:sy=2:ti=0
325 poke 1024+sy*40+sx,81
330 goto 60
340 print chr$(147);"game over  pops:";sc
350 print "press any key"
360 get a$:if a$="" then 360
370 goto 10
500 print chr$(19);"pops:";sc;" lives:";li;" speed:";20-sp;"  ";
510 return
