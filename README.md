![GIF](https://user-images.githubusercontent.com/90787010/185723072-0b7ddef6-81ec-4e02-b7f3-e6ca5cf40215.gif)
![GIF](https://user-images.githubusercontent.com/90787010/185723080-b23dc268-73cc-4fe9-8a1e-1a0dab5216df.gif)
![GIF](https://user-images.githubusercontent.com/90787010/185723079-41d870a4-67e7-497d-9840-03c3e734ee45.gif)
![GIF](https://user-images.githubusercontent.com/90787010/185723077-0f847f10-12fc-4421-81a9-90ce26f4866c.gif)

```
Pkg> activate --temp; dev .
julia> using Spinners
```

```
spinner()

t = @async sleep(5); Spinners.spinner(t, "🌑🌒🌓🌔🌕🌖🌗🌘")

t = @async sleep(5); Spinners.spinner(t, "........", 0.08, mode=:unfurl, before="Loading", after="Finished", cleanup=false)

braille="⠁⠂⠃⠄⠅⠆⠇⠈⠉⠊⠋⠌⠍⠎⠏⠐⠑⠒⠓⠔⠕⠖⠗⠘⠙⠚⠛⠜⠝⠞⠟⠠⠡⠢⠣⠤⠥⠦⠧⠨⠩⠪⠫⠬⠭⠮⠯⠰⠱⠲⠳⠴⠵⠶⠷⠸⠹⠺⠻⠼⠽⠾⠿⡀⡁⡂⡃⡄⡅⡆⡇⡈⡉⡊⡋⡌⡍⡎⡏⡐⡑⡒⡓⡔⡕⡖⡗⡘⡙⡚⡛⡜⡝⡞⡟⡠⡡⡢⡣⡤⡥⡦⡧⡨⡩⡪⡫⡬⡭⡮⡯⡰⡱⡲⡳⡴⡵⡶⡷⡸⡹⡺⡻⡼⡽⡾⡿⢀⢁⢂⢃⢄⢅⢆⢇⢈⢉⢊⢋⢌⢍⢎⢏⢐⢑⢒⢓⢔⢕⢖⢗⢘⢙⢚⢛⢜⢝⢞⢟⢠⢡⢢⢣⢤⢥⢦⢧⢨⢩⢪⢫⢬⢭⢮⢯⢰⢱⢲⢳⢴⢵⢶⢷⢸⢹⢺⢻⢼⢽⢾⢿⣀⣁⣂⣃⣄⣅⣆⣇⣈⣉⣊⣋⣌⣍⣎⣏⣐⣑⣒⣓⣔⣕⣖⣗⣘⣙⣚⣛⣜⣝⣞⣟⣠⣡⣢⣣⣤⣥⣦⣧⣨⣩⣪⣫⣬⣭⣮⣯⣰⣱⣲⣳⣴⣵⣶⣷⣸⣹⣺⣻⣼⣽⣾⣿"
t = @async sleep(5); Spinners.spinner(t, braille, 0.05, mode=:rand, after="⣿")
```
