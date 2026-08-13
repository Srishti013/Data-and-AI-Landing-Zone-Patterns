moved {
  from = azurerm_storage_data_lake_gen2_filesystem.this[0]
  to   = azurerm_storage_data_lake_gen2_filesystem.this["legacy"]
}

locals {
  storage_data_lake_gen2_filesystems = merge(
    var.storage_data_lake_gen2_filesystem == null ? {} : { legacy = var.storage_data_lake_gen2_filesystem },
    var.storage_data_lake_gen2_filesystems
  )
}

resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  for_each = local.storage_data_lake_gen2_filesystems

  name                     = each.value.name
  storage_account_id       = azurerm_storage_account.this.id
  default_encryption_scope = each.value.default_encryption_scope
  group                    = each.value.group
  owner                    = each.value.owner
  properties               = each.value.properties

  dynamic "ace" {
    for_each = each.value.ace == null ? [] : each.value.ace

    content {
      permissions = ace.value.permissions
      type        = ace.value.type
      id          = ace.value.id
      scope       = ace.value.scope
    }
  }
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = each.value.create
      delete = each.value.delete
      read   = each.value.read
      update = each.value.update
    }
  }

  # Gate the data-plane filesystem create on role propagation to avoid the 403
  # AuthorizationPermissionMismatch race when the caller's Storage Blob Data role
  # has not yet replicated at first apply.
  depends_on = [
    azurerm_storage_account.this,
    time_sleep.wait_role_propagation,
  ]
}

# Wait for storage-account role assignments to propagate before any data-plane call.
resource "time_sleep" "wait_role_propagation" {
  count           = length(var.role_assignments) > 0 ? 1 : 0
  create_duration = "120s"
  depends_on      = [azurerm_role_assignment.storage_account]
}

# Data Lake Gen2 paths (nested directories/files) with POSIX ACLs.
resource "azurerm_storage_data_lake_gen2_path" "this" {
  for_each = var.storage_data_lake_gen2_paths

  storage_account_id = azurerm_storage_account.this.id
  filesystem_name    = each.value.filesystem_name
  path               = each.value.path
  resource           = each.value.resource
  owner              = each.value.owner
  group              = each.value.group

  dynamic "ace" {
    for_each = each.value.ace == null ? [] : each.value.ace

    content {
      id          = ace.value.id
      permissions = ace.value.permissions
      scope       = ace.value.scope
      type        = ace.value.type
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  # Paths live inside a filesystem, so the filesystem must exist first. Without this,
  # Terraform can create paths before the managed filesystem, failing with
  # "404 The specified filesystem does not exist".
  depends_on = [
    azurerm_storage_account.this,
    azurerm_storage_data_lake_gen2_filesystem.this,
    time_sleep.wait_role_propagation,
  ]
}

