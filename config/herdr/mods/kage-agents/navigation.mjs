export function shortcutOrder(groups, folded) {
  return groups.filter(group => !folded.has(group.id)).flatMap(group => group.members.map(agent => agent.address));
}
