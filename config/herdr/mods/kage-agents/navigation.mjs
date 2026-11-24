export function shortcutOrder(groups, folded) {
  return groups.filter(group => !folded.has(group.id)).flatMap(group => group.members.map(agent => agent.address));
}

const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}\p{Ps}\p{Pi}]+/u, "").replace(/^\[ [!.] \] /, "").trim();

export function tabTitle(tab, l) {
  const prog = l?.program?.name;
  const live = clean(l?.title);
  const path = /^[~/]|^[A-Za-z]:\\/.test((l?.title ?? "").replace(/^[^\p{L}\p{N}~/]+/u, ""));
  const telling = live && live !== (l?.terminal ?? l?.address) && live !== prog && !path && !live.includes("@") && live.toLowerCase() !== l?.program?.key;
  return (tab.name === prog || !tab.named) && telling ? live : tab.name;
}

export function terminalEntries(spaces, panes, agents, focus) {
  const agentAddresses = new Set(agents.map(agent => agent.address));
  const byTab = new Map();
  for (const pane of panes) {
    if (!pane.terminal) continue;
    if (!byTab.has(pane.tab)) byTab.set(pane.tab, []);
    byTab.get(pane.tab).push(pane);
  }
  return spaces.flatMap(space => space.tabs.flatMap(tab => {
    const members = byTab.get(tab.id) ?? [];
    const children = members.map((pane, index) => {
      const label = tabTitle({ ...tab, name: pane.program?.name || "Terminal", named: false }, pane);
      return {
        ...pane,
        address: pane.terminal,
        agent: agentAddresses.has(pane.terminal),
        number: index + 1,
        name: label,
        selected: focus?.terminal === pane.terminal,
      };
    });
    if (!children.some(pane => !pane.agent)) return [];
    const lead = children.find(pane => pane.agent) ?? children[0];
    const label = tabTitle(tab, lead);
    return [{
      id: tab.id,
      space_name: space.name,
      machine: space.machine,
      number: String(tab.index),
      name: /^\d+$/.test(label) ? lead.program?.name || "Terminal" : label,
      panes: children,
      pane_count: members.length,
      selected: focus?.tab === tab.id || children.some(pane => pane.selected),
    }];
  }));
}
