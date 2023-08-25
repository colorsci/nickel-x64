var SystemPerformanceConnection,GPUPerformanceCharts,NetworkPerfChart,MemoryChart,IOChart,CPUChart;$(function(){var n=new CPUChart("CPU");new SystemPerformanceConnection("cpuPerfConnectionStatus",{cpuCallback:n.onMessageCallback})});
/*!
//@ sourceURL=tools/CpuPerformance/CpuPerformance.js
*/
