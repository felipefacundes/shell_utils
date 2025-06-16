pdfimg() {
echo -e "
# Convert specific pages of a PDF file to images using the pdftoppm command.\n# Converter páginas específicas de um arquivo PDF em imagens, utilizando o comando pdftoppm
"
    tput bold
    tput setaf 11
    echo -e "Converta determinadas páginas para uma imagem específica:"

    tput setaf 2
    echo "pdftoppm -<image_format> -f <first page> -l <last page> <pdf_filename> <image_name>"

    tput setaf 11
    echo -e "\nExemplo:"
    tput setaf 2
    echo "pdftoppm -jpeg -f 1 -l 2 Meu_Arquivo.pdf Minha_Imagem"

    tput sgr0
}

texttopdf_help() {
    echo -e "
# How to convert a text file (txt) to PDF using common commands like cupsfilter and soffice.\n# Como converter um arquivo de texto em PDF usando comandos comuns como cupsfilter e soffice.
"
    tput setaf 3
    echo "Use:"
    tput setaf 2
    echo -e "cupsfilter file.txt > file.pdf\n\nOr:\nsoffice --convert-to pdf file.txt\n\nSee more:\nhttps://www.baeldung.com/linux/convert-text-to-pdf"
    tput sgr0
}


encrypt_decrypt_pdf() {
    cat <<'EOF'
# encrypt / decrypt pdf | encriptar e descriptar pdf com ghostscript e com qpdf

# encrypt:
# ------ #
$ qpdf --encrypt your_password repeat_password 256 -- PDF.pdf PDF_protected.pdf
# ---------------------------------------------------------------------------- #
$ pdftk input.pdf output output.pdf user_pw PASSWORD
$ pdftk PDF2.pdf output PDF_encriptado.pdf user_pw USER_PASS owner_pw OWNER_PASS allow AllFeatures
$ pdftk PDF2.pdf output PDF_encriptado.pdf user_pw minha_senha owner_pw minha_senha_proprietario allow AllFeatures
# -------------------------------------------------------------------------------------------------------------- #

# decrypt:
# ------ #
$ qpdf --decrypt --password=PASSWORD PDF.pdf PDF_unprotected.pdf
# ------------------------------------------------------------ #
$ gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sPDFPassword=PASSWORD -sOutputFile=PDF_unprotected.pdf PDF_protected.pdf
# ------------------------------------------------------------ #
EOF
}

ghostscript_vectorDevices() {
    cat <<'EOF'
# pdf ghostscript settings / configurações de saída de pdf para ghostscript

# Pré-ajusta os "parâmetros do destilador" para uma das quatro configurações predefinidas:

# https://ghostscript.com/docs/9.54.0/VectorDevices.htm # item 7.2

    -dPDFSETTINGS=settings

/screen selects low-resolution output similar to the Acrobat Distiller (up to version X) "Screen Optimized" setting.
/screen seleciona saída de baixa resolução semelhante à configuração "Tela otimizada" do Acrobat Distiller (até a versão X).

/ebook selects medium-resolution output similar to the Acrobat Distiller (up to version X) "eBook" setting.
/ebook seleciona saída de resolução média semelhante à configuração "eBook" do Acrobat Distiller (até a versão X).

/printer selects output similar to the Acrobat Distiller "Print Optimized" (up to version X) setting.
/printer seleciona saída semelhante à configuração "Print Optimized" do Acrobat Distiller (até a versão X).

/prepress selects output similar to Acrobat Distiller "Prepress Optimized" (up to version X) setting.
/prepress seleciona saída semelhante à configuração "Prepress Optimized" do Acrobat Distiller (até a versão X).

/default selects output intended to be useful across a wide variety of uses, possibly at the expense of a larger output file.
/default seleciona a saída destinada a ser útil em uma ampla variedade de usos, possivelmente às custas de um arquivo de saída maior.

# Usage | Exemplo de uso:
$ gs -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -sOutputFile=output.pdf input.pdf

# Or
$ gs -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dColorImageResolution=150 -dGrayImageResolution=150 -dColorConversionStrategy=/RGB -dProcessColorModel=/DeviceRGB -dDownsampleColorImages=true -dDownsampleGrayImages=true -dDownsampleMonoImages=true -sOutputFile=output.pdf input.pdf

# With title:
$ i=input o=output; gs -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -sOutputFile="$o" -c "[/Title ($i) /DOCINFO pdfmark" -f "$i"

# Rotation/Orientation

    Orientation 1 → 90 ° counterclockwise.
    Orientation 2 → 180 ° (reverses, but not exactly a vertical flip).
    Orientation 3 → 270 ° counterclockwise (or 90th time).

$ i=input.pdf o=output.pdf; gs -o "$o" -sDEVICE=pdfwrite -c "<</Orientation 2>> setpagedevice" -f "$i"
EOF
}

pdf_metadata()
{
( cat <<'EOF'
# PDF tips

With exiftool:

List all metadata:

$ exiftool -s file.pdf

Clear all metadata:

$ exiftool -all='Felipe Facundes' file.pdf

Change Metadata:

$ exiftool -Title='PDF Created by Felipe Facundes' -Author='Felipe Facundes' \
    -Subject='Is this a pdf document or not?' file.pdf

==================================================================
With ghostscript:

Create a file named pdfmarks with similar content:

[ /Title (PDF Created by Felipe Facundes)
  /Author (Felipe Facundes)
  /Subject (Is this a pdf document or not?)
  /Keywords (PDF, PDF, PDF, PDF)
  /ModDate (D:20230404092842)
  /CreationDate (D:20230404092842)
  /Creator (A PDF Reader of Felipe Facundes)
  /Producer (Exhaustive work to produce this pdf)
  /DOCINFO pdfmark

then combine this pdfmarks file with a PDF, PS or EPS input file:

$ gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pdfwrite \
    -sOutputFile=output.pdf original.pdf pdfmarks

=================================================================

This is in the act library so you can edit PDF metadata from the command-line here as well.

$ npm install @lancejpollard/act -g
$ act update input.pdf --title foo --author bar --subject baz -k one -k two
EOF
) | less
}