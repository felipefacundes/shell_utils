gif() {
    if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-'EOF'
		# Um guia completo e profissional para criação de GIFs de altíssima qualidade a partir de vídeos, utilizando técnicas avançadas de processamento e otimização. Inclusive, com parte de vídeos do Youtube.
		EOF
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/gif-pt.md
    else
		cat <<-'EOF'
		# A complete and professional guide for creating high-quality GIFs from videos, using advanced processing and optimization techniques. Including from YouTube video segments.
		EOF
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/gif.md
    fi
}