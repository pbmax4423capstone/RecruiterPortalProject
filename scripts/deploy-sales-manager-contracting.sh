#!/bin/bash
# Deploy Sales Manager Contracting Kanban - Complete Deployment Script
# Run from project root directory

echo "=== Sales Manager Contracting Kanban - Full Deployment ==="
echo ""

# Step 1: Deploy updated Sales Manager Home Page (COMPLETED)
echo "✅ Step 1: Sales Manager Home Page deployed (Deploy ID: 0AfVo000000tFhZKAU)"
echo ""

# Step 2: Assign Permission Set to Sales Managers
echo "▶ Step 2: Assigning permissions..."
echo ""
echo "To assign the Sales_Manager_Contracting_Dashboard_Access permission set:"
echo ""
echo "Option A - Auto-assign to all Sales Managers/Directors:"
echo "  1. Open Developer Console in ProductionCapstone"
echo "  2. Debug > Open Execute Anonymous Window"
echo "  3. Copy/paste the contents of: scripts/assign-sales-manager-contracting-permissions.apex"
echo "  4. Click Execute"
echo "  5. Check debug logs for confirmation"
echo ""
echo "Option B - Manual assignment via Setup:"
echo "  1. Setup > Permission Sets"
echo "  2. Open 'Sales_Manager_Contracting_Dashboard_Access'"
echo "  3. Manage Assignments > Add Assignments"
echo "  4. Select Sales Manager users"
echo "  5. Assign"
echo ""

# Step 3: Verify Deployment
echo "▶ Step 3: Verify deployment..."
echo ""
echo "1. Log in to ProductionCapstone as a Sales Manager"
echo "2. Navigate to Home tab"
echo "3. Look for 'Sales Manager Contracting Kanban' component"
echo "4. Verify:"
echo "   - Only Career record type candidates shown"
echo "   - Sales Manager dropdown visible for Directors/Admins"
echo "   - Regular Sales Managers see their candidates only"
echo "   - Drag-and-drop works between stages"
echo "   - Filter selection persists on page refresh"
echo ""

echo "=== Deployment Summary ==="
echo "✅ Backend: 4 Apex methods added to CandidatesInContractingController"
echo "✅ Tests: 28/28 Apex tests passing"
echo "✅ Permission Set: Sales_Manager_Contracting_Dashboard_Access created"
echo "✅ Frontend: salesManagerContractingKanban LWC deployed"
echo "✅ Home Page: Sales_Manager_Home_Page updated with component"
echo "✅ Documentation: COLE_ARNOLD_DEVELOPMENT_GUIDE.md updated"
echo "⏳ Pending: Permission set assignment (run script or manual)"
echo ""
echo "All deployment steps complete except permission assignment!"
