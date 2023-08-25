var SystemPerformanceConnection,GPUPerformanceCharts,NetworkPerfChart,MemoryChart,IOChart,CPUChart;$(function(){var n=new MemoryChart("Memory",{showInUse:!0,showAvailablePages:!0,showCommittedPages:!0,showPagedPoolPages:!0,showNonPagedPoolPages:!0});new SystemPerformanceConnection("memoryPerfConnectionStatus",{memoryCallback:n.onMessageCallback})});
/*!
//@ sourceURL=tools/MemoryPerformance/MemoryPerformance.js
*/
