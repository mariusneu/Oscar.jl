using JSON

###############################################################################
## Graphs
###############################################################################
@register_serialization_type Graph{Directed} "Graph{Directed}"
@register_serialization_type Graph{Undirected} "Graph{Undirected}"
@register_serialization_type Edge

function save_object(s::SerializerState, g::Graph{T}) where T <: Union{Directed, Undirected}
  smallobject = pm_object(g)
  serialized = Polymake.call_function(Symbol("Core::Serializer"), :serialize, smallobject)
  jsonstr = Polymake.call_function(:common, :encode_json, serialized)
  save_data_json(s, jsonstr)
end


function load_object(s::DeserializerState, g::Type{Graph{T}}) where T <: Union{Directed, Undirected}
  smallobj = Polymake.call_function(:common, :deserialize_json_string, json(s.obj))
  return g(smallobj)
end

function save_object(s::SerializerState, e::Edge)
  save_data_array(s) do 
    save_object(s, src(e))
    save_object(s, dst(e))
  end
end

function load_object(s::DeserializerState, e::Type{Edge})
  return Edge(load_object(s, Int, 1), load_object(s, Int, 2))
end

###############################################################################
## Matroid
###############################################################################
@register_serialization_type Matroid "Matroid"

function save_object(s::SerializerState, m::Matroid) 
  gs = matroid_groundset(m)
  @req gs isa Vector{Int} "Groundset must be a Vector{Int}"

  save_data_dict(s) do
    save_object(s, pm_object(m), :matroid)
    save_object(s, gs, :groundset)
    save_object(s, create_gs2num(gs), :gs2num)
  end
end


function load_object(s::DeserializerState, m::Type{Matroid})
  mt = load_object(s, Polymake.BigObject, :matroid)
  grds = load_object(s, Vector{Int}, :groundset)
  gs2num = load_object(s, Dict{Int,Int}, :gs2num)
  return m(mt, grds, gs2num)
end


###############################################################################
## IncidenceMatrix
###############################################################################
@register_serialization_type Polymake.IncidenceMatrixAllocated{Polymake.NonSymmetric}

function save_object(s::SerializerState, IM::IncidenceMatrix)
  serialized = Polymake.call_function(Symbol("Core::Serializer"), :serialize, IM)
  jsonstr = Polymake.call_function(:common, :encode_json, serialized)
  save_data_json(s, jsonstr)
end

function load_object(s::DeserializerState, ::Type{<: IncidenceMatrix})
  IM = Polymake.call_function(:common, :deserialize_json_string, json(s.obj))
  return IM
end


###############################################################################
## SimplicialComplex
###############################################################################
@register_serialization_type SimplicialComplex

function save_object(s::SerializerState, K::SimplicialComplex)
  save_object(s, pm_object(K))
end

function load_object(s::DeserializerState, K::Type{SimplicialComplex})
  bigobject = Polymake.call_function(:common, :deserialize_json_string, json(s.obj))
  return K(bigobject)
end

###############################################################################
## Phylogenetic Trees
###############################################################################
@register_serialization_type PhylogeneticTree 

function save_object(s::SerializerState, PT::PhylogeneticTree)
  save_object(s, pm_object(PT))
end

function load_object(s::DeserializerState, T::Type{PhylogeneticTree}, dict::Dict)
  bigobject = Polymake.call_function(:common, :deserialize_json_string, json(dict))
  return T(bigobject)
end
