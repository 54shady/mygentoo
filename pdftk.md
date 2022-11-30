## PDF 操作

app-text/pdftk PDF 分割成单页

	pdftk all.pdf burst

app-text/poppler PDF转化txt

	pdftotext demo.pdf

### 快速翻译八千多页的arm手册

1. 将手册分割成单页(获得到单页pdf pg_0001.pdf...)

	pdftk armv8.pdf burst

2. 将第68页pdf转成txt(这里输出pg_0068.txt)

	pdftotext pg_0068.pdf

3. 将单页的内容进行中文翻译(app-i18n/translate-shell)

	cat pg_0068.txt | trans -e bing en:zh-CN -

