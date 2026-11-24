/* KernelScope X — static homepage interactions; all web stats are simulated. */
(() => {
  "use strict";
  const $ = id => document.getElementById(id);

  const menu = $("menu-toggle"), mobile = $("mobile-nav");
  menu.addEventListener("click", () => {
    const open = mobile.hidden;
    mobile.hidden = !open;
    menu.setAttribute("aria-expanded", String(open));
    menu.textContent = open ? "Close ×" : "Menu";
  });
  mobile.querySelectorAll("a").forEach(link => link.addEventListener("click", () => {
    mobile.hidden = true;
    menu.setAttribute("aria-expanded", "false");
    menu.textContent = "Menu";
  }));
  document.addEventListener("keydown", event => {
    if (event.key === "Escape" && !mobile.hidden) menu.click();
  });

  // No timers, moving text, 3D rotations, or automatic animations.
  const datasets = {
    cpu: { name: "CPU utilization · sample trend", readings: [24,28,27,34,39,34,36,33,32,31,38,40,35,33,28,31,26,30,24,25], color: "var(--teal)" },
    ram: { name: "Physical memory · sample trend", readings: [39,40,40,41,43,44,43,44,46,47,48,47,49,50,51,51,52,52,53,53], color: "var(--blue)" },
    threads: { name: "Thread count · sample trend", readings: [37,40,39,42,45,42,44,43,47,49,47,51,54,52,55,53,56,57,55,58], color: "var(--accent)" }
  };
  function showTrend(key) {
    const dataset = datasets[key];
    if (!dataset) return;
    $("trend-name").textContent = dataset.name;
    const p = dataset.readings.map((v, i) => (4 + i * 392 / 19).toFixed(1) + "," + (99-v).toFixed(1)).join(" ");
    $("trend-line").setAttribute("points", p);
    $("trend-line").style.stroke = dataset.color;
    document.querySelectorAll("[data-metric]").forEach(button => {
      button.setAttribute("aria-pressed", String(button.dataset.metric === key));
    });
  }
  document.querySelectorAll("[data-metric]").forEach(button => button.addEventListener("click", () => showTrend(button.dataset.metric)));
  showTrend("cpu");

  const workload = [
    {name:"P1",arrival:0,burst:8,index:0},
    {name:"P2",arrival:1,burst:4,index:1},
    {name:"P3",arrival:2,burst:9,index:2},
    {name:"P4",arrival:3,burst:5,index:3}
  ];
  function simulate(algorithm) {
    const jobs=workload.map(j=>({...j,remaining:j.burst,start:-1,finish:-1}));
    const segments=[];
    let now=0,finished=0;
    function append(name,start,end){
      const previous=segments[segments.length-1];
      if(previous && previous.name===name && previous.end===start) previous.end=end;
      else segments.push({name,start,end});
    }
    function run(job,duration){
      if(job.start<0)job.start=now;
      append(job.name,now,now+duration);
      now+=duration;
      job.remaining-=duration;
      if(job.remaining===0){job.finish=now;finished++;}
    }
    const byArrival=[...jobs].sort((a,b)=>a.arrival-b.arrival||a.index-b.index);
    if(algorithm==="rr"){
      let next=0;const queue=[];
      while(finished<jobs.length){
        while(next<byArrival.length&&byArrival[next].arrival<=now)queue.push(byArrival[next++]);
        if(!queue.length){const soon=byArrival[next].arrival;append("Idle",now,soon);now=soon;continue;}
        const job=queue.shift();run(job,Math.min(3,job.remaining));
        while(next<byArrival.length&&byArrival[next].arrival<=now)queue.push(byArrival[next++]);
        if(job.remaining>0)queue.push(job);
      }
    }else{
      while(finished<jobs.length){
        const ready=jobs.filter(job=>job.remaining>0 && job.arrival<=now);
        if(!ready.length){const soon=Math.min(...jobs.filter(j=>j.remaining>0).map(j=>j.arrival));append("Idle",now,soon);now=soon;continue;}
        if(algorithm==="sjf")ready.sort((a,b)=>a.burst-b.burst||a.arrival-b.arrival||a.index-b.index);
        else ready.sort((a,b)=>a.arrival-b.arrival||a.index-b.index);
        run(ready[0],ready[0].remaining);
      }
    }
    const avg=fn=>jobs.reduce((sum,j)=>sum+fn(j),0)/jobs.length;
    return {segments,time:now,wait:avg(j=>j.finish-j.arrival-j.burst),turnaround:avg(j=>j.finish-j.arrival),response:avg(j=>j.start-j.arrival)};
  }
  function showSchedule(algorithm) {
    const result=simulate(algorithm);
    const gantt=$("gantt");
    gantt.replaceChildren();
    const palette=["#fa6b76","#85b4ff","#60ddca","#f1c27a"];
    for(const segment of result.segments){
      const block=document.createElement("div");
      block.style.flex=String(segment.end-segment.start)+" 1 0";
      const index=parseInt(segment.name.slice(1),10)-1;
      block.style.backgroundColor=segment.name==="Idle"?"#536174":palette[index];
      block.title=segment.name+" / "+segment.start+"–"+segment.end;
      block.textContent=segment.name;
      gantt.append(block);
    }
    $("avg-wait").textContent=result.wait.toFixed(2);
    $("avg-turn").textContent=result.turnaround.toFixed(2);
    $("avg-response").textContent=result.response.toFixed(2);
    $("finish-time").textContent=String(result.time);
    document.querySelectorAll("[data-algorithm]").forEach(button=>{
      button.setAttribute("aria-pressed",String(button.dataset.algorithm===algorithm));
    });
  }
  document.querySelectorAll("[data-algorithm]").forEach(button=>button.addEventListener("click",()=>showSchedule(button.dataset.algorithm)));
  showSchedule("fcfs");

  // A teaching example, not access to the host computer's page table.
  const mapping = new Map([[0,5],[1,9],[2,1],[3,12]]);
  function translate() {
    const raw=$("logical-address").value.trim();
    const logical=Number(raw);
    const display=$("memory-output");
    if(!raw || !/^\d+$/.test(raw) || !Number.isSafeInteger(logical) || logical>1000000) {
      $("page-number").textContent="—";
      $("offset-number").textContent="—";
      $("frame-number").textContent="—";
      $("physical-address").textContent="Invalid input";
      $("translation-info").textContent="Enter a non-negative integer up to 1,000,000 bytes.";
      display.classList.add("error");
      return;
    }
    const page=Math.floor(logical/1024),offset=logical%1024,frame=mapping.get(page);
    $("page-number").textContent=String(page);
    $("offset-number").textContent=String(offset);
    $("frame-number").textContent=frame===undefined?"—":String(frame);
    if(frame===undefined){
      $("physical-address").textContent="Unmapped page";
      $("translation-info").textContent="This example has no valid entry for page "+page+".";
      display.classList.add("error");
    }else{
      const physical=frame*1024+offset;
      $("physical-address").textContent=physical.toLocaleString("en-US");
      $("translation-info").textContent="Frame "+frame+" × 1024 + "+offset+" = "+physical+".";
      display.classList.remove("error");
    }
  }
  $("memory-form").addEventListener("submit",event=>{event.preventDefault();translate();});
  translate();
})();