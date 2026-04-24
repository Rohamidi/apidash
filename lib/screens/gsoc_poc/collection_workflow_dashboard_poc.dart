import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';

// ─── Data Models ──────────────────────────────────────────────────────────────

enum _WorkflowRunState { idle, running, success, failure }

class _CollectionData {
  const _CollectionData({
    required this.id,
    required this.name,
    required this.description,
    required this.requestCount,
    required this.statusLabel,
    required this.statusType,
    required this.lastUpdated,
    required this.branch,
    required this.pendingChanges,
  });

  final String id;
  final String name;
  final String description;
  final int requestCount;
  final String statusLabel;
  final _StatusType statusType;
  final String lastUpdated;
  final String branch;
  final int pendingChanges;
}

class _WorkflowStep {
  const _WorkflowStep({
    required this.icon,
    required this.title,
    required this.method,
    required this.endpoint,
    required this.description,
    required this.authNote,
  });

  final IconData icon;
  final String title;
  final String method;
  final String endpoint;
  final String description;
  final String authNote;
}

class _CommitEntry {
  const _CommitEntry({
    required this.hash,
    required this.message,
    required this.author,
    required this.timeAgo,
    this.isHead = false,
  });

  final String hash;
  final String message;
  final String author;
  final String timeAgo;
  final bool isHead;
}

enum _StatusType { ready, draft, review }

// ─── Static Demo Data ──────────────────────────────────────────────────────────

const _kCollections = [
  _CollectionData(
    id: 'col-001',
    name: 'User Authentication',
    description: 'OAuth 2.0 + token refresh flows',
    requestCount: 4,
    statusLabel: 'Workflow ready',
    statusType: _StatusType.ready,
    lastUpdated: '12 min ago',
    branch: 'main',
    pendingChanges: 0,
  ),
  _CollectionData(
    id: 'col-002',
    name: 'Product Catalog',
    description: 'Fetch, filter, and paginate products',
    requestCount: 8,
    statusLabel: 'Draft',
    statusType: _StatusType.draft,
    lastUpdated: '1 hour ago',
    branch: 'feat/catalog',
    pendingChanges: 2,
  ),
  _CollectionData(
    id: 'col-003',
    name: 'Checkout Flow',
    description: 'Cart, pricing, and order submission',
    requestCount: 6,
    statusLabel: 'Needs review',
    statusType: _StatusType.review,
    lastUpdated: 'Yesterday',
    branch: 'fix/checkout',
    pendingChanges: 5,
  ),
];

const _kSteps = [
  _WorkflowStep(
    icon: Icons.key_rounded,
    title: 'Authenticate',
    method: 'POST',
    endpoint: '/auth/login',
    description:
        'Exchanges credentials for a signed JWT access token and refresh token pair.',
    authNote: 'No auth required',
  ),
  _WorkflowStep(
    icon: Icons.inventory_2_outlined,
    title: 'Fetch Products',
    method: 'GET',
    endpoint: '/products',
    description:
        'Retrieves the product listing using the Bearer token from step 1.',
    authNote: 'Bearer token from step 1',
  ),
  _WorkflowStep(
    icon: Icons.shopping_cart_checkout_rounded,
    title: 'Create Checkout',
    method: 'POST',
    endpoint: '/checkout',
    description:
        'Posts selected product IDs and quantities to create a checkout session.',
    authNote: 'Bearer token + product IDs from step 2',
  ),
];

const _kCommitsBase = [
  _CommitEntry(
    hash: 'a12f9c3',
    message: 'Updated auth flow headers',
    author: 'you',
    timeAgo: '2h ago',
    isHead: true,
  ),
  _CommitEntry(
    hash: 'e87c014',
    message: 'Added refresh token request',
    author: 'you',
    timeAgo: '1d ago',
  ),
  _CommitEntry(
    hash: '3b90fa2',
    message: 'Initial collection scaffold',
    author: 'you',
    timeAgo: '3d ago',
  ),
];

// ─── Main Widget ───────────────────────────────────────────────────────────────

class CollectionWorkflowDashboardPoc extends StatefulWidget {
  const CollectionWorkflowDashboardPoc({super.key});

  @override
  State<CollectionWorkflowDashboardPoc> createState() =>
      _CollectionWorkflowDashboardPocState();
}

class _CollectionWorkflowDashboardPocState
    extends State<CollectionWorkflowDashboardPoc>
    with TickerProviderStateMixin {
  int _selectedCollection = 0;
  int _selectedStep = 0;
  _WorkflowRunState _runState = _WorkflowRunState.idle;
  bool _committed = false;
  List<_CommitEntry> _commits = List.from(_kCommitsBase);

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onSelectCollection(int index) {
    setState(() {
      _selectedCollection = index;
      _selectedStep = 0;
      _runState = _WorkflowRunState.idle;
      _committed = false;
      _commits = List.from(_kCommitsBase);
    });
  }

  void _runWorkflow() async {
    setState(() => _runState = _WorkflowRunState.running);
    await Future.delayed(const Duration(milliseconds: 1400));
    setState(() => _runState = _WorkflowRunState.success);
  }

  void _createCommit() {
    final col = _kCollections[_selectedCollection];
    setState(() {
      _committed = true;
      _commits = [
        _CommitEntry(
          hash: 'b42e7a1',
          message: 'Save workflow: ${col.name}',
          author: 'you',
          timeAgo: 'just now',
          isHead: true,
        ),
        ..._kCommitsBase.map(
          (c) => _CommitEntry(
            hash: c.hash,
            message: c.message,
            author: c.author,
            timeAgo: c.timeAgo,
            isHead: false,
          ),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          kVSpacer10,
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 256,
                  child: _CollectionPanel(
                    collections: _kCollections,
                    selected: _selectedCollection,
                    onSelect: _onSelectCollection,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _WorkflowPanel(
                    steps: _kSteps,
                    selectedStep: _selectedStep,
                    runState: _runState,
                    pulseAnim: _pulseAnim,
                    onSelectStep: (i) => setState(() => _selectedStep = i),
                    onRun: _runState == _WorkflowRunState.running
                        ? null
                        : _runWorkflow,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 272,
                  child: _VersionPanel(
                    collection: _kCollections[_selectedCollection],
                    commits: _commits,
                    committed: _committed,
                    runState: _runState,
                    onCommit: _committed ? null : _createCommit,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final col = _kCollections[_selectedCollection];
    return Row(
      children: [
        Icon(
          Icons.account_tree_rounded,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'Workflow Builder',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        _BranchBadge(branch: col.branch),
        const Spacer(),
      ],
    );
  }
}

// ─── Collection Panel ──────────────────────────────────────────────────────────

class _CollectionPanel extends StatelessWidget {
  const _CollectionPanel({
    required this.collections,
    required this.selected,
    required this.onSelect,
  });

  final List<_CollectionData> collections;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PanelShell(
      header: Row(
        children: [
          Icon(
            Icons.folder_copy_outlined,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            'Collections',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            '${collections.length}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: collections.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, i) => _CollectionTile(
          data: collections[i],
          selected: selected == i,
          onTap: () => onSelect(i),
        ),
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _CollectionData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? cs.primaryContainer.withValues(alpha: 0.55)
                : cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? cs.primary.withValues(alpha: 0.5)
                  : cs.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: selected ? cs.primary : cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusDot(type: data.statusType),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                data.description,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.circle_outlined,
                    size: 10,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${data.requestCount} requests',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    data.lastUpdated,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (data.pendingChanges > 0) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.fiber_manual_record,
                      size: 6,
                      color: _statusColor(data.statusType, context),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      data.statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _statusColor(data.statusType, context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Workflow Panel ────────────────────────────────────────────────────────────

class _WorkflowPanel extends StatelessWidget {
  const _WorkflowPanel({
    required this.steps,
    required this.selectedStep,
    required this.runState,
    required this.pulseAnim,
    required this.onSelectStep,
    required this.onRun,
  });

  final List<_WorkflowStep> steps;
  final int selectedStep;
  final _WorkflowRunState runState;
  final Animation<double> pulseAnim;
  final ValueChanged<int> onSelectStep;
  final VoidCallback? onRun;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final step = steps[selectedStep];

    return _PanelShell(
      header: Row(
        children: [
          Icon(Icons.device_hub_rounded, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            'Workflow Sequence',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _RunStateBadge(state: runState),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Node list
          for (int i = 0; i < steps.length; i++) ...[
            _WorkflowNodeTile(
              index: i,
              data: steps[i],
              selected: selectedStep == i,
              runState: runState,
              pulseAnim: pulseAnim,
              onTap: () => onSelectStep(i),
            ),
            if (i < steps.length - 1) _ConnectorLine(runState: runState),
          ],

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Detail card
          _StepDetailCard(step: step),

          const SizedBox(height: 16),

          // Run button
          SizedBox(
            height: 38,
            child: FilledButton.icon(
              onPressed: onRun,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: runState == _WorkflowRunState.running
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text(
                runState == _WorkflowRunState.running
                    ? 'Running…'
                    : 'Run workflow preview',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),

          if (runState == _WorkflowRunState.success) ...[
            const SizedBox(height: 10),
            _ResultBanner(
              icon: Icons.check_circle_rounded,
              message:
                  'All 3 requests completed successfully. No errors detected.',
              color: cs.primary,
            ),
          ],
          if (runState == _WorkflowRunState.failure) ...[
            const SizedBox(height: 10),
            _ResultBanner(
              icon: Icons.error_rounded,
              message:
                  'Workflow failed at step 2. Check auth token propagation.',
              color: cs.error,
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkflowNodeTile extends StatelessWidget {
  const _WorkflowNodeTile({
    required this.index,
    required this.data,
    required this.selected,
    required this.runState,
    required this.pulseAnim,
    required this.onTap,
  });

  final int index;
  final _WorkflowStep data;
  final bool selected;
  final _WorkflowRunState runState;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isRunning = runState == _WorkflowRunState.running;
    final isSuccess = runState == _WorkflowRunState.success;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? cs.primaryContainer.withValues(alpha: 0.5)
                : cs.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? cs.primary.withValues(alpha: 0.55)
                  : cs.outlineVariant.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Step indicator
              _StepIndicator(
                index: index + 1,
                isRunning: isRunning,
                isSuccess: isSuccess,
                pulseAnim: pulseAnim,
              ),
              const SizedBox(width: 12),
              // Icon
              Icon(
                data.icon,
                size: 18,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              // Labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: selected ? cs.primary : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _MethodBadge(method: data.method),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            data.endpoint,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.index,
    required this.isRunning,
    required this.isSuccess,
    required this.pulseAnim,
  });

  final int index;
  final bool isRunning;
  final bool isSuccess;
  final Animation<double> pulseAnim;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isSuccess) {
      return Icon(Icons.check_circle_rounded, size: 20, color: cs.primary);
    }

    if (isRunning) {
      return AnimatedBuilder(
        animation: pulseAnim,
        builder: (_, _) => Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.primary.withValues(alpha: 0.15 + 0.2 * pulseAnim.value),
            border: Border.all(color: cs.primary, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.surfaceContainerHigh,
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        '$index',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ConnectorLine extends StatelessWidget {
  const _ConnectorLine({required this.runState});

  final _WorkflowRunState runState;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive =
        runState == _WorkflowRunState.running ||
        runState == _WorkflowRunState.success;

    return Padding(
      padding: const EdgeInsets.only(left: 26),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 1.5,
                height: 20,
                color: isActive
                    ? cs.primary.withValues(alpha: 0.6)
                    : cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                isActive ? 'token passed →' : 'passes data →',
                style: TextStyle(
                  fontSize: 10,
                  color: isActive
                      ? cs.primary.withValues(alpha: 0.8)
                      : cs.onSurfaceVariant.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDetailCard extends StatelessWidget {
  const _StepDetailCard({required this.step});

  final _WorkflowStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(step.icon, size: 15, color: cs.primary),
              const SizedBox(width: 7),
              Text(
                step.title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
              const Spacer(),
              _MethodBadge(method: step.method),
              const SizedBox(width: 6),
              Text(
                step.endpoint,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.link_rounded, size: 12, color: cs.onSurfaceVariant),
              const SizedBox(width: 5),
              Text(
                step.authNote,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Version Panel ─────────────────────────────────────────────────────────────

class _VersionPanel extends StatelessWidget {
  const _VersionPanel({
    required this.collection,
    required this.commits,
    required this.committed,
    required this.runState,
    required this.onCommit,
  });

  final _CollectionData collection;
  final List<_CommitEntry> commits;
  final bool committed;
  final _WorkflowRunState runState;
  final VoidCallback? onCommit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasChanges = !committed && collection.pendingChanges > 0;

    return _PanelShell(
      header: Row(
        children: [
          Icon(Icons.commit_rounded, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            'Version Control',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _BranchBadge(branch: collection.branch),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sync status row
          _VersionInfoRow(
            icon: committed
                ? Icons.cloud_done_rounded
                : Icons.cloud_upload_outlined,
            label: 'Sync',
            value: committed ? 'Up to date' : 'Local changes',
            valueColor: committed
                ? cs.primary
                : cs.error.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 10),
          _VersionInfoRow(
            icon: Icons.source_rounded,
            label: 'Branch',
            value: collection.branch,
          ),
          const SizedBox(height: 10),
          _VersionInfoRow(
            icon: Icons.edit_note_rounded,
            label: 'Changes',
            value: committed
                ? 'None'
                : '${collection.pendingChanges} file${collection.pendingChanges != 1 ? 's' : ''}',
            valueColor: committed ? null : cs.tertiary,
          ),

          const SizedBox(height: 16),

          // Staged changes
          if (hasChanges) ...[
            _StagedChanges(collection: collection),
            const SizedBox(height: 16),
          ],

          // Commit CTA
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              onPressed: onCommit,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(
                  color: onCommit != null
                      ? cs.outline
                      : cs.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              icon: Icon(
                committed ? Icons.check_rounded : Icons.save_alt_rounded,
                size: 15,
              ),
              label: Text(
                committed ? 'Committed' : 'Create commit',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Commit history
          Text(
            'Commit history',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          kVSpacer10,
          for (final commit in commits) ...[_CommitRow(commit: commit)],
        ],
      ),
    );
  }
}

class _StagedChanges extends StatelessWidget {
  const _StagedChanges({required this.collection});

  final _CollectionData collection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.tertiary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Staged changes',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.tertiary,
            ),
          ),
          const SizedBox(height: 6),
          _StagedFile(
            name: '${collection.name.toLowerCase().replaceAll(' ', '_')}.json',
            changeType: 'M',
          ),
          const SizedBox(height: 3),
          _StagedFile(name: 'workflow.yaml', changeType: 'A'),
        ],
      ),
    );
  }
}

class _StagedFile extends StatelessWidget {
  const _StagedFile({required this.name, required this.changeType});

  final String name;
  final String changeType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = changeType == 'A' ? cs.primary : cs.tertiary;

    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(3),
          ),
          alignment: Alignment.center,
          child: Text(
            changeType,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: cs.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CommitRow extends StatelessWidget {
  const _CommitRow({required this.commit});

  final _CommitEntry commit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: commit.isHead ? cs.primary : cs.outlineVariant,
                  border: commit.isHead
                      ? Border.all(color: cs.primary, width: 1.5)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        commit.hash,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (commit.isHead) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'HEAD',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  commit.message,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: commit.isHead ? FontWeight.w500 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${commit.author} · ${commit.timeAgo}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ────────────────────────────────────────────────────────────

class _PanelShell extends StatelessWidget {
  const _PanelShell({required this.header, required this.child});

  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              border: Border(
                bottom: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: header,
          ),
          // Panel body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodBadge extends StatelessWidget {
  const _MethodBadge({required this.method});

  final String method;

  static const _colors = {
    'GET': Color(0xFF16A34A),
    'POST': Color(0xFF2563EB),
    'PUT': Color(0xFFD97706),
    'PATCH': Color(0xFF7C3AED),
    'DELETE': Color(0xFFDC2626),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[method] ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _BranchBadge extends StatelessWidget {
  const _BranchBadge({required this.branch});

  final String branch;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fork_right_rounded, size: 11, color: cs.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(
            branch,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.type});

  final _StatusType type;

  @override
  Widget build(BuildContext context) {
    final color = _dotColor(type, context);
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Color _dotColor(_StatusType type, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (type) {
      case _StatusType.ready:
        return cs.primary;
      case _StatusType.draft:
        return cs.tertiary;
      case _StatusType.review:
        return cs.error.withValues(alpha: 0.8);
    }
  }
}

class _RunStateBadge extends StatelessWidget {
  const _RunStateBadge({required this.state});

  final _WorkflowRunState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (state) {
      _WorkflowRunState.idle => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'idle',
          style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
        ),
      ),
      _WorkflowRunState.running => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: cs.tertiary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'running…',
          style: TextStyle(
            fontSize: 10,
            color: cs.tertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      _WorkflowRunState.success => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'passed',
          style: TextStyle(
            fontSize: 10,
            color: cs.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      _WorkflowRunState.failure => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'failed',
          style: TextStyle(
            fontSize: 10,
            color: cs.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    };
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionInfoRow extends StatelessWidget {
  const _VersionInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────────────

Color _statusColor(_StatusType type, BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  switch (type) {
    case _StatusType.ready:
      return cs.primary;
    case _StatusType.draft:
      return cs.tertiary;
    case _StatusType.review:
      return cs.error;
  }
}
