# HISTORY #

Changes to JGraphT in each version:

- **version 0.9.0** (06-Dec-2013): 
	- Move to github for source control, and Apache Maven for build, contributed by Andreas Schnaiter, Owen Jacobson, and Isaac Kleinman.
	- Add source/target vertices to edge events to fix sf.net bug 3486775, spotted by Frank Mori Hess.
	- Add `EdmondsBlossomShrinking` algorithm, contributed by Alejandro R. Lopez del Huerto.
	- Fix empty diameter calculation in `FloydWarshallShortestPaths`, contributed by Ernst de Ridder (bug spotted by Jens Lehmann)
	- Add `HopcroftKarpBipartiteMatching` and `MinSourceSinkCut`, contributed by Joris Kinable
	- Fix multiple bugs in `StoerWagnerMinimumCut`, contributed by Ernst de Ridder
	- Fix path weight bug in `FloydWarshallShortestPaths`, contributed by Michal Pasieka
	- Add `PrimMinimumSpanningTree`, contributed by Alexey Kudinkin
	- Add `DirectedWeightedPseudograph`, and fix 'DirectedMultigraph' contributed by Adam Gouge
	- More KSP bugfixes (spotted by Sebastian Mueller, fixed by Guillaume Boulmier)
	- Add `KuhnMunkresMinimalWeightBipartitePerfectMatching` and associated generators+interfaces (contributed by Alexey Kudinkin)
	- Add cycle enumeration (contributed by Nikolay Ognyanov, originally from http://code.google.com/p/niographs/ )
	- Update `removeAllEdges` to match specification (contributed by Graham Hill)
	- Add `TarjanLowestCommonAncestor`, contributed by Leo Crawford
	- Add `JGraphXAdapter`, contributed by Sebastian Hubenschmid and JeanYves Tinevez
	- Add LGPL/EPL dual licensing, coordinated by Oliver Kopp
	- Refactoring for `DirectedAcyclicGraph`, contributed by javierj

- **version 0.8.3** (20-Jan-2012): 
	- fix regression in `DOTExporter` inadvertently introduced by `0.8.2` changes.
	- Add `GridGraphGenerator`, contributed by Assaf Mizrachi.
	- Return coloring from ChromaticNumber, contributed by Harshal Vora.
	- Fix bugs in KSP, contributed by Guillaume Boulmier; note that these bugfixes worsen the running time.  
	- Fix an object identity bug in CycleDetector, contributed by Matt Sarjent.
	-Add StoerWagnerMinimumCut, contributed by Robby McKilliam.
	- Fix `MANIFEST.MF`, spotted by Olly.
	- Make `FloydWarshallShortestPaths.getShortestPaths` unidirectional, contributed by Yuriy Nakonechnyy.

- **version 0.8.2** (27-Nov-2010): 
	- Clean up `FibonacciHeapNode` constructor, as suggested by Johan
Henriksson.
	- Optimize and enhance `FloydWarshallShortestPaths`, contributed by Soren Davidsen.
	- Optimize `ChromaticNumber`,pointed out by gpaschos@netscape.net.
	- Add unit test for `FloydWarshallShortestPaths` for bug noticed by
Andrea Pagani. 
	- Add vertex factory validation to `RandomGraphGenerator` to prevent a confusing problem encountered by Andrea Pagani.
	- Add `KruskalMinimumSpanningTree` and `UnionFind`, contributed by Tom Conerly.
	- Add attributes to `DOTExporter`, based on suggestion from Chris Lott.
	- Fix inefficient assertion in `TopologicalOrderIterator`, spotted by 
Peter Lawrey.
	- Fix induced subgraph bug with addition of edge to underlying graph, contributed by Michele Mancioppi.
	- Make `getEdgeWeight` delegate to `DefaultWeightedEdge.getWeight`, spotted by Michael Lindig.
	- Add maven support, contributed by Adrian Marte.

- **version 0.8.1** (3-Jul-2009): 
	- Enhanced `GmlExporter` with customized labels and ID's, contributed by Trevor Harmon.
	- Added new algorithms `HamiltonianCycle`, `ChromaticNumber` and `EulerianCircuit`, plus new generators `HyperCubeGraphGenerator`, `StarGraphGenerator`, and `CompleteBipartiteGraphGenerator`, all contributed by Andrew Newell.
	- Fix bug with vertices which are equals but not identity-same in graphs allowing loops, spotted by Michael Michaud.
	- Fix bug in `EquivalenceIsomorphismInspector`, reported by Tim Engler.  		- Add `toString` for shortest paths wrapper, spotted by Achim Beutel.
	- Add `FloydWarshallShortestPaths`, contributed by Tom Larkworthy.
	- Enhance `DijskstraShortestPath` to support `GraphPath` interface.
	- Add `GraphUnion` (with directed and undirected variants), contributed by Ilya Razenshteyn.

- **version 0.8.0** (Sept-2008): 
	- Moved to JDK 1.6.
	- Fixed problem with `RandomGraphGenerator` reported by Mario Rossi.
	- Added `CompleteGraphGenerator`, contributed by Tim Shearouse.
	- Fixed `FibonacciHeap` performance problem reported by Jason Lenderman.
	- Made `DotExporter` reject illegal vertex ID's, contributed by Holger Brandl.
	- Fixed bogus assertion for topological sort over empty
graph, spotted by Harris Lin.
	- Added scale-free graph generator and `EdmondsKarpMaximumFlow`, contributed by Ilya Razenshteyn.
	- Added `DirectedAcyclicGraph`, contributed by Peter Giles.
	- Added protected `getWeight` accessor to `DefaultWeightedEdge`, likewise `getSource` and `getTarget` on `DefaultEdge`.
	- Optimized iterators to skip calling event firing routines when there are no listeners, and used `ArrayDeque` in a number of places, per suggestion from Ross Judson.
	- Improvements to `StrongConnectivityInspector` and OSGi bundle support contributed by Christian Soltenborn.

- **version 0.7.3** (Jan-2008):
	- Patch to `JGraphModelAdapter.removeVertex` provided by Hookahey.
	- Added `ParanoidGraph`.
	- Removed obsolete `ArrayUtil` (spotted by Boente).
	- Added `GraphPath`, and used it to fix mistake in `0.7.2` (k-shortest-paths was returning a private data structure,
as discovered by numerous users).
	- Fixed `EdgeReversedGraph.getAllEdges` (spotted by neumanns@users.sf.net).
	- Fixed incorrect assertion in `TopologicalOrderIterator` constructor.
	- Enabled assertions in JUnit tests.
	- Fixed NPE in `BellmanFordShortestPath.getCost`.
	- Fixed a few problems spotted by findbugs.

- **version 0.7.2** (Sept-2007): 
	- Added `TransitiveClosure`, contributed by Vinayak Borkar.
	- Added biconnectivity/cutpoint inspection, k-shortest-paths, and masked
subgraphs, all contributed by Guillaume Boulmier.
	- Made some Graphs helper methods even more generic, as suggested by JongSoo.
	- Test and fixes for (Directed)NeighborIndex submitted by Andrew Berman.
	- Added `AsUnweighted(Directed)Graph` and `AsWeightedGraph`, contributed by Lucas Scharenbroich.
	- Dropped support for retroweaver.

- **version 0.7.1** (March-2007): 
	- Fixed some bugs in `CycleDetector` reported by Khanh Vu, and added more testcases for it.
	- Fixed bugs in `DepthFirstIterator` reported by Welson Sun, and added WHITE/GRAY/BLACK states and `vertexFinished` listener event.
	- Exposed `Subgraph.getBase()`, and parameterized `Subgraph` on graph type (per suggestion from Aaron Harnly).
	- Added `EdgeReversedView`.
	- Added `GmlExporter` (contributed by Dimitrios Michail), plus `DOTExporter` and `GraphMLExporter` (both contributed by Trevor Harmon).
	- Enhanced `TopologicalOrderIterator` to take an optional Queue parameter for tie-breaking (per suggestion from JongSoo Park).
	- Fixed some documentation errors reported by Guillaume Boulmier.

- **version 0.7.0** (July-2006) : 
	- Upgraded to JDK 1.5 (generics support added by Christian Hammer with help from Hartmut Benz and John Sichi).
	- Added `(Directed)NeighborIndex` and `MatrixExporter`, contributed by Charles Fry.
	- Added BellmanFord, contributed by Guillaume Boulmier of France Telecom.
	- Removed never-used `LabeledElement`.
	- Renamed package from `org._3pq.jgrapht` to `org.jgrapht`.
	- Made various breaking change to interfaces; edge collections are now Sets, not Lists.
	- Added Touchgraph converter, contributed by Carl Anderson

- **version 0.6.0** (July-2005) : 
	- Upgraded to JDK 1.4, taking advantage of its new linked hash set/map containers to make edge/vertex set order-deterministic
	- Added support for custom edge lists.
	- Fixed various serialization and Subgraph issues.
	- Added to `JGraphModelAdapter` support for JGraph's "dangling" edges; its constructors have slightly changed and now forbid `null` values.
	- Improved interface to `DijskstraShortestPath`, and added radius support to `ClosestFirstIterator`.
	- Added new `StrongConnectivityInspector` algorithm (contributed by Christian Soltenborn) and `TopologicalOrderIterator` (contributed by Marden Neubert).
	- Deleted deprecated `TraverseUtils`.
	- Upgraded to JGraph `5.6.1.1`.

- **version 0.5.3** (June-2004) : 
	- Removed Subgraph verification of element's identity to base graph, upgraded to JGraph 4.0
	- Added the `VisioExporter` which was contributed by Avner Linder
	- minor bug fixes and improvements.

- **version 0.5.2** (March-2004) : 
	- Serialization improvements, fixes to subgraphs and listenable graphs
	- added support for JGraph > JGraphT change propagation for JGraph adapter (contributed by Erik Postma)
	- upgraded to JGraph 3.1, various bug fixes and improvements.

- **version 0.5.1** (November-2003) : 
	- Semantics of `Graph.clone()` has changed, please check the documentation if you're using it.
	- Added Dijkstra's shortest path, vertex cover approximations, new graph generation framework
	- upgraded to JGraph 3.0
	- various bug fixes and API improvements.

- **version 0.5.0** (14-Aug-2003) : 
	- a new connectivity inspector added
	- edge API refactored to be simpler
	- improved ant build
	- improved event model
	- all known bugs were fixed, documentation clarifications, other small improvements. 
	- API of 0.5.0 is not 100% backward compatible with 0.4.1 but upgrade is simple and straightforward.

- **version 0.4.1** (05-Aug-2003) : 
	- A new adapter to JGraph that provides graph visualizations, new depth-first and breadth-first iteration algorithms
	- various bug fixes and refactoring
	- moved unit-tests to a separate folder hierarchy and added more unit-tests.

- **version 0.4.0** (July-2003) : Initial public release.
