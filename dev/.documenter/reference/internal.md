
# Internal API {#Internal-API}
<details class='jldocstring custom-block' open>
<summary><a id='Base.map-Tuple{Any, Metaweb{<:Global}}' href='#Base.map-Tuple{Any, Metaweb{<:Global}}'><span class="jlbinding">Base.map</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
Base.map(fcn, net::Metaweb{ST,<:Global}) where {ST}
```


Applies the function `fcn` to the [`Global`](/reference/public#SpeciesInteractionSamplers.Global) [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb) `net`. Overload of the `map` method for `Global` networks.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/map.jl#L1-L5" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Base.map-Union{Tuple{SC}, Tuple{Any, Metaweb{SC}}} where SC<:Union{var"#s22", var"#s1", var"#s46"} where {var"#s22"<:Spatial, var"#s1"<:Temporal, var"#s46"<:Spatiotemporal}' href='#Base.map-Union{Tuple{SC}, Tuple{Any, Metaweb{SC}}} where SC<:Union{var"#s22", var"#s1", var"#s46"} where {var"#s22"<:Spatial, var"#s1"<:Temporal, var"#s46"<:Spatiotemporal}'><span class="jlbinding">Base.map</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
Base.map(fcn, net::Metaweb{ST,SC}) where {ST,SC}
```


foo


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/map.jl#L10-L14" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.networks-Tuple{Metaweb}' href='#SpeciesInteractionSamplers.networks-Tuple{Metaweb}'><span class="jlbinding">SpeciesInteractionSamplers.networks</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
networks(mw::Metaweb)
```


Returns the local networks associated with the input metaweb `mw`.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/network.jl#L43-L47" target="_blank" rel="noreferrer">source</a></Badge>

</details>

