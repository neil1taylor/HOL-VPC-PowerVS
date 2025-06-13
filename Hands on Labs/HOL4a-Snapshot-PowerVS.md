# Example 1
Let’s say you have a volume (volume1) and you're using IBM FlashCopy to take snapshots.

On Day 1, you take your first snapshot.
On Day 7, you take a second snapshot.

## Let’s break down

1. volume1 is your active volume.
1. toc1 = metadata (table of contents) representing the block structure of volume1 * at the time of snapshot Day 1.
1. toc2 = copy of toc1, created when the Day 1 snapshot is taken.
1. toc3 = new metadata created when the Day 7 snapshot is taken.

# How Snapshots Work Internally

## Day 1 – First Snapshot
- A snapshot is taken by copying the metadata toc1 to toc2.
- Any time a block in volume1 is modified after this point, the system:
    - Preserves the original block.
    - Updates toc1 (for the live volume) to point to the new version.
    - Leaves toc2 pointing to the preserved block.
- Result: toc1 and toc2 begin to diverge.

## Day 7 – Second Snapshot
- A new snapshot is taken; this copies the current toc1 into toc3.
- Now, you have:
    - toc1: live volume
    - toc2: snapshot from Day 1
    - toc3: snapshot from Day 7

## Subsequent Writes
- If a block that is still referenced by both toc2 and toc3 is modified:
    - The original block is copied to preserve consistency for both snapshots.
    - Both toc2 and toc3 must now point to that preserved version.
    - toc1 (live volume) points to the new modified block.
- Over time, as more writes occur, all the TOCs (metadata) drift apart as they point to different versions of blocks.

## Result
- Each snapshot maintains a consistent view of volume1 at the time it was taken.
- The system ensures data integrity by:
    - Preserving original data blocks.
    - Updating the corresponding TOCs when shared data changes.
- The more snapshots you have, and the more write-intensive your workload is, the more storage overhead you'll have due to the need to track and store multiple versions of blocks.


# Example 2

## Day 1: Block 100 = "ABC"
- Snapshot1 records pointer to block 100.

## Day 3: Block 100 updated to "DEF"
- FlashCopy copies "ABC" to repository.
- volume1 gets new block 200 = "DEF"
- snapshot1 still points to old block 100 ("ABC")

## Day 7: New snapshot taken
- Snapshot2 points to block 200 ("DEF")

## Day 8: Block 100 updated again to "XYZ"
- FlashCopy sees that block 200 is referenced by snapshot2.
- It preserves "DEF" again in repository.
- Writes "XYZ" as new block 300.
- Now:
    - snapshot1 → "ABC"
    - snapshot2 → "DEF"
    - volume1 → "XYZ"



## Best Practice for HANA DB

1. Freeze DB
    - `hdbsql -u SYSTEM -p ***** -i <SID> 'BACKUP DATA FOR FULL SYSTEM CREATE SNAPSHOT'`
1. Immediately take snapshot (FlashCopy / PowerVS API)
1. Unfreeze DB
    - `hdbsql -u SYSTEM -p ***** -i <SID> 'BACKUP DATA FOR FULL SYSTEM CLOSE SNAPSHOT'`

## LAB Performing snapshot and restore
1. To take a snapshot
```
ic pi instance snapshot create INSTANCE_ID --name day1 --volumes "ID1,ID2,ID3"

ic pi instance snapshot create  b01250a0-f78f-4cd5-bd91-ad1f7f3090aa --name day1 --volumes 029ba901-8a9d-4d63-92e2-17ce7cff1ea4
Creating snapshot for instance b01250a0-f78f-4cd5-bd91-ad1f7f3090aa under account SAP-Training-India as user Suraj.Bharadwaj@ibm.com...
OK
Snapshot day1 with ID of 57ab48d5-2b1a-4640-9533-4aec671ce739 has started.
```

1. List the snapshots and track status of operation
```
ic pi instance snapshot list --json
{
    "snapshots": [
        {
            "action": "snapshot",
            "creationDate": "2025-06-12T18:55:25.000Z",
            "crn": "crn:v1:bluemix:public:power-iaas:wdc07:a/cb83fe3c3d9b4308a919413aa69e9e37:5c52b0f1-2834-4377-802b-cb4f7ad5339c:snapshot:57ab48d5-2b1a-4640-9533-4aec671ce739",
            "lastUpdateDate": "2025-06-12T18:55:38.000Z",
            "name": "day11",
            "percentComplete": 100,
            "pvmInstanceID": "b01250a0-f78f-4cd5-bd91-ad1f7f3090aa",
            "snapshotID": "57ab48d5-2b1a-4640-9533-4aec671ce739",
            "status": "available",
            "volumeSnapshots": {
                "029ba901-8a9d-4d63-92e2-17ce7cff1ea4": "a39b5b75-41df-46a8-9a01-5ed45f0458f5"
            }
        }
       ]
 }
```

1. Day3 restore the snapshot
Shutdown VM:
```
ic  pi instance snapshot restore INSTANCE_ID --snapshot DAY1_SNAPSHOT_ID
```

# How Cloning Works (Step-by-Step)

## PowerVS cloning is a 3-stage process:

1. Prepare – creates a group snapshot of the selected volumes
2. Start – initializes the FlashCopy process
3. Execute – actually clones the data to new volumes


## 1. Prepare the Clone
**Purpose:** Lock in a consistent state of the source volumes before cloning begins.

**Key Requirements:**

* Minimum 2 volumes required (unless doing a single-volume clone)
* At least one volume must be “in-use”
* Volumes must belong to same storage pool
* Applications must be quiesced to ensure consistency
* Command: `ibmcloud pi volume clone create --name <clone-name> --volume-ids <id1,id2,...>`

**Statuses:**
1. preparing → snapshot in progress
1. prepared → ready for cloning
1. failed → snapshot failed (check logs, fix errors)

## 2. Start the Clone
**Purpose:** Begin the actual FlashCopy operation.

This is where PowerVS uses FlashCopy to quickly initialize copy-on-write maps between source and target volumes.

**Command:** `ibmcloud pi volume clone start --volume-clones-id <clone-id>`

**Status:**
1. starting → initializing copy
1. available → ready to proceed to clone


## 3. Execute the Clone
**Purpose:** Create full volume copies from the snapshot.

This step involves background copying of all blocks from source to target. Once complete, new volumes are independent.

**Command:** `ibmcloud pi volume clone execute --volume-clones-id <clone-id> --name <base-name-for-new-volumes>`

**Optional flags:**

- rollbackPrepare=true|false – rollback behavior on failure
- targetReplicationEnabled=true|false – replicate clone if needed
- targetStorageTier – set tier (must be same pool)

**Status:**
1. executing → cloning in progress
2. completed → clone finished
3. failed → error occurred (check rollback status)


## Single Volume Clone (Fast Track)
- If cloning only one volume, you can bypass the group prepare/start/execute:

`ibmcloud pi volume clone-async --volume-id <id> --name <clone-name>`

## Cancel a Clone (If Needed)
If cloning fails or is no longer needed, you can cancel it:

`ibmcloud pi volume clone cancel --volume-clones-id <clone-id> --force true`

## Delete a Clone Request
After clone is completed, failed, or cancelled, you can delete the request metadata:

`ibmcloud pi volume clone delete --volume-clones-id <clone-id>`

## Monitor Status

- Get status of a specific clone: `ibmcloud pi volume clone get --volume-clones-id <clone-id>`
- List all clone requests: `ibmcloud pi volume clone list --filter <status>`

## Important Technical Considerations

| Topic                        | Description                                                  |
| ---------------------------- | ------------------------------------------------------------ |
| **Consistency**              | Ensured only if **application is quiesced** before Prepare   |
| **Storage Pool Restriction** | All volumes must be in the **same storage pool**             |
| **Replication**              | Can be inherited or configured for clones                    |
| **No Resizing**              | Disk size can't be changed during clone                      |
| **Clone Name Format**        | Final volume name: `clone-<base>-<random>-N`                 |
| **Failure Handling**         | Use `rollbackPrepare` to control cleanup behavior on failure |

## Clone Summary

| Task                     | Tool/Action               |
| ------------------------ | ------------------------- |
| Start clone (group)      | Prepare → Start → Execute |
| Start clone (single vol) | `volume clone-async`      |
| Track progress           | `volume clone get`        |
| Cancel/rollback          | `volume clone cancel`     |
| Clean up                 | `volume clone delete`     |

## Hands on
1. Clone of single disk
```
ic pi volume clone-async create shared --volumes 029ba901-8a9d-4d63-92e2-17ce7cff1ea4
```

1. Tracked the status using
```
ic pi volume fcm 029ba901-8a9d-4d63-92e2-17ce7cff1ea4
Getting the flash copy mapping for volume 029ba901-8a9d-4d63-92e2-17ce7cff1ea4 under account SAP-Training-India as user Suraj.Bharadwaj@ibm.com...
Flash Copy Name   Source Volume Name            Target Volume Name                        Status    Start Time                 Copy Rate   Progress
fcmap2            volume-data-1-029ba901-8a9d   volume-clone-shared-20044-e9f5588e-f6c3   copying   0001-01-01T00:00:00.000Z   140         0
```
