import{_ as e,c as a,o as s,a6 as n}from"./chunks/framework.DV0yOlkA.js";const t="/SpeciesInteractionSamplers.jl/dev/assets/concept.z8Br-1TZ.png",p="/SpeciesInteractionSamplers.jl/dev/assets/design.Cf-aeJq2.png",u=JSON.parse('{"title":"SpeciesInteractionSamplers.jl","description":"","frontmatter":{},"headers":[],"relativePath":"index.md","filePath":"index.md","lastUpdated":null}'),i={name:"index.md"},l=n('<h1 id="speciesinteractionsamplers-jl" tabindex="-1">SpeciesInteractionSamplers.jl <a class="header-anchor" href="#speciesinteractionsamplers-jl" aria-label="Permalink to &quot;SpeciesInteractionSamplers.jl&quot;">​</a></h1><p>Documentation for <code>SpeciesInteractionSamplers.jl</code>.</p><p><img src="'+t+'" alt=""></p><p><img src="'+p+`" alt=""></p><div class="language-@example vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">@example</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line highlighted"><span>energy = 200</span></span>
<span class="line"><span>λ = generate(NicheModel())</span></span>
<span class="line"><span>relabd = generate(NormalizedLogNormal(σ=0.2), λ)</span></span>
<span class="line"><span>θ = realizable(λ, NeutrallyForbiddenLinks(relabd, energy))</span></span>
<span class="line"><span>ζ = realize(θ)</span></span>
<span class="line"><span></span></span>
<span class="line"><span>δ = detectability(λ, RelativeAbundanceScaled(relabd, 20.))</span></span>
<span class="line"><span></span></span>
<span class="line"><span>detect(ζ, δ)</span></span></code></pre></div>`,5),c=[l];function r(o,d,_,m,h,g){return s(),a("div",null,c)}const b=e(i,[["render",r]]);export{u as __pageData,b as default};
