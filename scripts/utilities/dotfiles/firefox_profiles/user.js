//
/* You may copy+paste this file and use it as it is.
 *
 * If you make changes to your about:config while the program is running, the
 * changes will be overwritten by the user.js when the application restarts.
 *
 * To make lasting changes to preferences, you will have to edit the user.js.
 * 
 * Coloque esse arquivo user.js dentro da pasta profile, obtida em about:profiles
 * 
 */

/****************************************************************************
 * Betterfox                                                                *
 * "Ad meliora"                                                             *
 * version: 146                                                             *
 * url: https://github.com/yokoffing/Betterfox                              *
****************************************************************************/

/****************************************************************************
 * SECTION: FASTFOX (Seção de Otimizações de Velocidade)                   *
****************************************************************************/
/** GENERAL (Configurações Gerais) ***/
user_pref("gfx.content.skia-font-cache-size", 32); // Aumenta cache de fontes para renderização mais rápida

/** GFX (Configurações Gráficas) ***/
user_pref("gfx.webrender.layer-compositor", true); // Habilita compositor de camadas para melhor performance gráfica
user_pref("gfx.canvas.accelerated.cache-items", 32768); // Aumenta itens no cache de canvas acelerado
user_pref("gfx.canvas.accelerated.cache-size", 4096); // Aumenta tamanho do cache de canvas acelerado
user_pref("webgl.max-size", 16384); // Aumenta tamanho máximo para texturas WebGL

/** DISK CACHE (Cache em Disco) ***/
user_pref("browser.cache.disk.enable", false); // DESATIVA cache em disco (usa só RAM) - pode poupar SSD mas depende da sua RAM

/** MEMORY CACHE (Cache em Memória) ***/
user_pref("browser.cache.memory.capacity", 131072); // Aumenta MUITO o cache na RAM (512MB)
user_pref("browser.cache.memory.max_entry_size", 20480); // Aumenta tamanho máximo de cada item no cache
user_pref("browser.sessionhistory.max_total_viewers", 4); // Limita quantas páginas são mantidas em cache para voltar/avançar
user_pref("browser.sessionstore.max_tabs_undo", 10); // Aumenta número de abas que podem ser reabertas após fechar

/** MEDIA CACHE (Cache de Mídia) ***/
user_pref("media.memory_cache_max_size", 262144); // Aumenta cache de mídia na RAM (1GB)
user_pref("media.memory_caches_combined_limit_kb", 1048576); // Aumenta limite total de cache de mídia (1GB)
user_pref("media.cache_readahead_limit", 600); // Aumenta pré-carregamento de vídeos/áudio
user_pref("media.cache_resume_threshold", 300); // Aumenta limite para retomar mídia sem rebuffer

/** IMAGE CACHE (Cache de Imagens) ***/
user_pref("image.cache.size", 10485760); // Aumenta cache de imagens (10MB)
user_pref("image.mem.decode_bytes_at_a_time", 65536); // Aumenta bytes decodificados de cada vez

/** NETWORK (Configurações de Rede) ***/
user_pref("network.http.max-connections", 1800); // Aumenta MUITO conexões HTTP simultâneas
user_pref("network.http.max-persistent-connections-per-server", 10); // Aumenta conexões persistentes por servidor
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5); // Aumenta conexões urgentes
user_pref("network.http.request.max-start-delay", 5); // Reduz atraso máximo para iniciar requisições
user_pref("network.http.pacing.requests.enabled", false); // DESATIVA espaçamento de requisições - pode sobrecarregar servidores
user_pref("network.dnsCacheEntries", 10000); // Aumenta MUITO entradas no cache DNS
user_pref("network.dnsCacheExpiration", 3600); // Aumenta tempo que DNS fica em cache (1 hora)
user_pref("network.ssl_tokens_cache_capacity", 10240); // Aumenta cache de tokens SSL

/** SPECULATIVE LOADING (Pré-carregamento) ***/
user_pref("network.http.speculative-parallel-limit", 0); // DESATIVA completamente pré-carregamento paralelo
user_pref("network.dns.disablePrefetch", true); // DESATIVA pré-busca de DNS - sites podem carregar mais devagar
user_pref("network.dns.disablePrefetchFromHTTPS", true); // DESATIVA pré-busca DNS de sites HTTPS
user_pref("browser.urlbar.speculativeConnect.enabled", false); // DESATIVA conexão especulativa da barra de endereços
user_pref("browser.places.speculativeConnect.enabled", false); // DESATIVA conexão especulativa de favoritos/histórico
user_pref("network.prefetch-next", false); // DESATIVA pré-carregamento de links na página

/****************************************************************************
 * SECTION: SECUREFOX (Seção de Segurança e Privacidade)                   *
****************************************************************************/
/** TRACKING PROTECTION (Proteção contra Rastreamento) ***/
user_pref("browser.contentblocking.category", "strict"); // Define bloqueio de conteúdo como "ESTRITO"
user_pref("browser.download.start_downloads_in_tmp_dir", true); // Começa downloads em pasta temporária
user_pref("browser.uitour.enabled", false); // DESATIVA os tours interativos do Firefox
user_pref("privacy.globalprivacycontrol.enabled", true); // Habilita sinalização Global Privacy Control

/** OCSP & CERTS / HPKP ***/
user_pref("security.OCSP.enabled", 1); // 0 DESATIVA COMPLETAMENTE verificação OCSP de certificados - RISCO DE SEGURANÇA!
user_pref("privacy.antitracking.isolateContentScriptResources", true); // Isola recursos de scripts de conteúdo
user_pref("security.csp.reporting.enabled", false); // DESATIVA relatórios de violação de CSP

/** SSL / TLS ***/
user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true); // Trata negociação insegura SSL como quebrada
user_pref("browser.xul.error_pages.expert_bad_cert", true); // Mostra detalhes técnicos em erros de certificado
user_pref("security.tls.enable_0rtt_data", false); // DESATIVA 0-RTT do TLS 1.3 - mais seguro mas um pouco mais lento

/** DISK AVOIDANCE (Evitar uso de Disco) ***/
user_pref("browser.privatebrowsing.forceMediaMemoryCache", true); // Força cache de mídia na RAM no modo privativo
user_pref("browser.sessionstore.interval", 60000); // Aumenta intervalo de salvamento automático de sessão (1 minuto)

/** SHUTDOWN & SANITIZING (Encerramento e Limpeza) ***/
user_pref("privacy.history.custom", true); // Permite configuração personalizada de histórico
user_pref("browser.privatebrowsing.resetPBM.enabled", true); // Habilita reset ao sair do modo privativo

/** SEARCH / URL BAR (Busca e Barra de Endereços) ***/
user_pref("browser.urlbar.trimHttps", true); // Remove "https://" da barra ao exibir
user_pref("browser.urlbar.untrimOnUserInteraction.featureGate", true); // Reexibe "https://" ao interagir
user_pref("browser.search.separatePrivateDefault.ui.enabled", true); // Permite motor de busca diferente no modo privativo
user_pref("browser.search.suggest.enabled", false); // DESATIVA sugestões de busca - pode atrapalhar
user_pref("browser.urlbar.quicksuggest.enabled", false); // DESATIVA sugestões rápidas na barra - pode atrapalhar
user_pref("browser.urlbar.groupLabels.enabled", false); // DESATIVA rótulos de grupos na barra
/** Se desativado impede que o firefox salve formulários o que pode ser um saco ***/
user_pref("browser.formfill.enable", true); // false DESATIVA autocompletar formulários - INCONVENIENTE (Pode ser um saco, então deixe true)!
user_pref("network.IDN_show_punycode", true); // Mostra Punycode em vez de caracteres internacionais em URLs

/** HTTPS-ONLY MODE (Modo Apenas HTTPS) ***/
user_pref("dom.security.https_only_mode", true); // Habilita modo HTTPS-only (conecta só por HTTPS)
user_pref("dom.security.https_only_mode_error_page_user_suggestions", true); // Mostra sugestões em erros HTTPS-only

/** PASSWORDS (Senhas) ***/
/** Impede que o Firefox capture senhas de formulários não padrão. ***/
user_pref("signon.formlessCapture.enabled", true); // false DESATIVA captura de senhas em formulários não-padrão
user_pref("signon.privateBrowsingCapture.enabled", false); // DESATIVA captura de senhas no modo privativo
user_pref("network.auth.subresource-http-auth-allow", 1); // Permite autenticação HTTP em sub-recursos (1 = permitir)
user_pref("editor.truncate_user_pastes", false); // DESATIVA truncamento de textos colados

/** EXTENSIONS (Extensões) ***/
user_pref("extensions.enabledScopes", 5); // Define escopos permitidos para extensões

/** HEADERS / REFERERS (Cabeçalhos/Referências) ***/
user_pref("network.http.referer.XOriginTrimmingPolicy", 2); // Política rigorosa para enviar referências

/** CONTAINERS (Contêineres) ***/
user_pref("privacy.userContext.ui.enabled", true); // Habilita interface de contêineres

/** VARIOUS (Diversos) ***/
user_pref("pdfjs.enableScripting", false); // DESATIVA JavaScript em PDFs - mais seguro

/** SAFE BROWSING (Navegação Segura) ***/
user_pref("browser.safebrowsing.downloads.remote.enabled", true); // false DESATIVA verificação remota de downloads - RISCO!

/** MOZILLA ***/
user_pref("permissions.default.desktop-notification", 2); // Bloqueia notificações por padrão
user_pref("permissions.default.geo", 2); // Bloqueia geolocalização por padrão
user_pref("geo.provider.network.url", "https://beacondb.net/v1/geolocate"); // Usa serviço diferente para geolocalização
user_pref("browser.search.update", false); // DESATIVA atualizações de motores de busca
user_pref("permissions.manager.defaultsUrl", ""); // Remove URL padrão para gerenciamento de permissões
user_pref("extensions.getAddons.cache.enabled", false); // DESATIVA cache para busca de extensões

/** TELEMETRY (Telemetria) ***/
user_pref("datareporting.policy.dataSubmissionEnabled", false); // DESATIVA envio de dados
user_pref("datareporting.healthreport.uploadEnabled", false); // DESATIVA relatórios de saúde
user_pref("toolkit.telemetry.unified", false); // DESATIVA telemetria unificada
user_pref("toolkit.telemetry.enabled", false); // DESATIVA telemetria geral
user_pref("toolkit.telemetry.server", "data:,"); // Configura servidor de telemetria como vazio
user_pref("toolkit.telemetry.archive.enabled", false); // DESATIVA arquivamento de telemetria
user_pref("toolkit.telemetry.newProfilePing.enabled", false); // DESATIVA relatórios de novo perfil
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false); // DESATIVA relatórios no encerramento
user_pref("toolkit.telemetry.updatePing.enabled", false); // DESATIVA relatórios de atualização
user_pref("toolkit.telemetry.bhrPing.enabled", false); // DESATIVA relatórios de travamentos
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false); // DESATIVA relatórios do primeiro encerramento
user_pref("toolkit.telemetry.coverage.opt-out", true); // Opt-out de cobertura de telemetria
user_pref("toolkit.coverage.opt-out", true); // Opt-out de cobertura geral
user_pref("toolkit.coverage.endpoint.base", ""); // Remove endpoint de cobertura
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false); // DESATIVA telemetria do feed da nova aba
user_pref("browser.newtabpage.activity-stream.telemetry", false); // DESATIVA telemetria da nova aba
user_pref("datareporting.usage.uploadEnabled", false); // DESATIVA envio de dados de uso

/** EXPERIMENTS (Experimentos) ***/
user_pref("app.shield.optoutstudies.enabled", false); // DESATIVA estudos Shield (experimentos)
user_pref("app.normandy.enabled", false); // DESATIVA Normandy (estudos de comportamento)
user_pref("app.normandy.api_url", ""); // Remove URL da API Normandy

/** CRASH REPORTS (Relatórios de Queda) ***/
user_pref("breakpad.reportURL", ""); // Remove URL para relatórios de queda
user_pref("browser.tabs.crashReporting.sendReport", false); // DESATIVA envio de relatórios de queda de abas

/****************************************************************************
 * SECTION: PESKYFOX (Seção de Coisas Chatas/Inconvenientes)               *
****************************************************************************/
/** MOZILLA UI (Interface da Mozilla) ***/
user_pref("extensions.getAddons.showPane", false); // DESATIVA painel de obtenção de extensões
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false); // DESATIVA recomendações de extensões
user_pref("browser.discovery.enabled", false); // DESATIVA descoberta de recursos
user_pref("browser.shell.checkDefaultBrowser", false); // DESATIVA verificação de navegador padrão
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false); // DESATIVA recomendações de extensões na nova aba
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false); // DESATIVA recomendações de recursos na nova aba
user_pref("browser.preferences.moreFromMozilla", false); // DESATIVA seção "Mais da Mozilla" nas preferências
user_pref("browser.aboutConfig.showWarning", false); // DESATIVA aviso do about:config
user_pref("browser.startup.homepage_override.mstone", "ignore"); // Ignora atualização da página inicial por versão
user_pref("browser.aboutwelcome.enabled", false); // DESATIVA tela de boas-vindas
user_pref("browser.profiles.enabled", true); // Habilita gerenciamento de múltiplos perfis

/** THEME ADJUSTMENTS (Ajustes de Tema) ***/
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // Habilita estilos personalizados antigos
user_pref("browser.compactmode.show", true); // Mostra modo compacto
user_pref("browser.privateWindowSeparation.enabled", false); // DESATIVA separação visual de janelas privativas (WINDOWS)

/** AI (Inteligência Artificial) ***/
user_pref("browser.ml.enable", false); // DESATIVA machine learning no navegador
user_pref("browser.ml.chat.enabled", false); // DESATIVA chat com IA
user_pref("browser.ml.chat.menu", false); // DESATIVA menu de chat com IA
user_pref("browser.tabs.groups.smart.enabled", false); // DESATIVA agrupamento inteligente de abas
user_pref("browser.ml.linkPreview.enabled", false); // DESATIVA pré-visualização de links com IA

/** FULLSCREEN NOTICE (Aviso de Tela Cheia) ***/
user_pref("full-screen-api.transition-duration.enter", "0 0"); // Remove transição ao entrar em tela cheia
user_pref("full-screen-api.transition-duration.leave", "0 0"); // Remove transição ao sair de tela cheia
user_pref("full-screen-api.warning.timeout", 0); // Remove atraso do aviso de tela cheia

/** URL BAR (Barra de Endereços) ***/
user_pref("browser.urlbar.trending.featureGate", false); // DESATIVA tendências na barra de endereços

/** NEW TAB PAGE (Nova Página de Aba) ***/
user_pref("browser.newtabpage.activity-stream.default.sites", ""); // Remove sites padrão da nova aba
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false); // DESATIVA sites patrocinados
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false); // DESATIVA principais notícias
user_pref("browser.newtabpage.activity-stream.showSponsored", false); // DESATIVA conteúdo patrocinado
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false); // DESATIVA caixas de seleção para patrocinados

/** DOWNLOADS (Downloads) ***/
user_pref("browser.download.manager.addToRecentDocs", false); // DESATIVA adicionar downloads a documentos recentes (Windows)

/** PDF ***/
user_pref("browser.download.open_pdf_attachments_inline", true); // Abre anexos PDF inline em vez de baixar

/** TAB BEHAVIOR (Comportamento de Abas) ***/
user_pref("browser.bookmarks.openInTabClosesMenu", false); // DESATIVA fechar menu ao abrir favoritos em nova aba
user_pref("browser.menu.showViewImageInfo", true); // Habilita "Ver informações da imagem" no menu
user_pref("findbar.highlightAll", true); // Habilita destacar todas as ocorrências na busca
user_pref("layout.word_select.eat_space_to_next_word", false); // DESATIVA incluir espaço ao selecionar palavras

/****************************************************************************
 * START: MY OVERRIDES                                                      *
****************************************************************************/
// visit https://github.com/yokoffing/Betterfox/wiki/Common-Overrides
// visit https://github.com/yokoffing/Betterfox/wiki/Optional-Hardening
// Enter your personal overrides below this line:



/****************************************************************************
 * SECTION: SMOOTHFOX                                                       *
****************************************************************************/
// visit https://github.com/yokoffing/Betterfox/blob/main/Smoothfox.js
// Enter your scrolling overrides below this line:



/****************************************************************************
 * END: BETTERFOX                                                           *
****************************************************************************/
