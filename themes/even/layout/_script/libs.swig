{%- if theme.fancybox -%}
  {%- set fancybox_js = 'fancybox/jquery.fancybox.pack.js' -%}
{%- endif -%}

{%-
  set js_libs = {
    jquery: 'jquery/jquery.min.js',
    slideout: 'slideout/slideout.js',
    fancybox: fancybox_js,
    nprogress: nprogress_js,
  }
-%}

{%- for lib in js_libs -%}
  {%- if lib -%}
    <script type="text/javascript" src="{{ url_for('lib') }}/{{ lib }}"></script>
  {%- endif -%}
{%- endfor -%}

<!-- Hotjar Tracking Code for https://notes.yaohwu.xyz/ -->
<script>
    (function(h,o,t,j,a,r){
        h.hj=h.hj||function(){(h.hj.q=h.hj.q||[]).push(arguments)};
        h._hjSettings={hjid:2982407,hjsv:6};
        a=o.getElementsByTagName('head')[0];
        r=o.createElement('script');r.async=1;
        r.src=t+h._hjSettings.hjid+j+h._hjSettings.hjsv;
        a.appendChild(r);
    })(window,document,'https://static.hotjar.com/c/hotjar-','.js?sv=');
</script>
