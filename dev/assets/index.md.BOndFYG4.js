import{_ as s,c as i,o as a,a7 as e}from"./chunks/framework.ClzvfdMd.js";const n="/SpeciesInteractionSamplers.jl/dev/assets/concept.z8Br-1TZ.png",t="/SpeciesInteractionSamplers.jl/dev/assets/design.DUbBvpF6.png",_=JSON.parse('{"title":"SpeciesInteractionSamplers.jl","description":"","frontmatter":{},"headers":[],"relativePath":"index.md","filePath":"index.md","lastUpdated":null}'),l={name:"index.md"},p=e('<h1 id="speciesinteractionsamplers-jl" tabindex="-1">SpeciesInteractionSamplers.jl <a class="header-anchor" href="#speciesinteractionsamplers-jl" aria-label="Permalink to &quot;SpeciesInteractionSamplers.jl&quot;">​</a></h1><p>Documentation for <code>SpeciesInteractionSamplers.jl</code>.</p><p><img src="'+n+'" alt=""></p><p><img src="'+t+`" alt=""></p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">feasible_network </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> generate</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">NicheModel</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">())</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">relative_abundance </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> generate</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">NormalizedLogNormal</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(σ</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">0.2</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">), feasible_network)</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">energy </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> 500</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">realization_rate </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> realizable!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">NeutrallyForbiddenLinks</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(energy), feasible_network, relative_abundance)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">realized_network </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> realize!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(feasible_network)</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">detectability_network </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> detectability</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">RelativeAbundanceScaled</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">10.0</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">),feasible_network, relative_abundance)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">detected_network </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> detect!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(feasible_network, detectability_network)</span></span></code></pre></div><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>Detected Global Metaweb</span></span></code></pre></div>`,6),h=[p];function k(r,d,c,E,o,g){return a(),i("div",null,h)}const F=s(l,[["render",k]]);export{_ as __pageData,F as default};
