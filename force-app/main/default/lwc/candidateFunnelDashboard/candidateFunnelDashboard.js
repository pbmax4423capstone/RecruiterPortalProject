import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, MessageContext } from 'lightning/messageService';
import DARK_MODE_CHANNEL from '@salesforce/messageChannel/DarkModeChannel__c';
import getActiveFunnelData from '@salesforce/apex/CandidateFunnelController.getActiveFunnelData';
import { loadScript } from 'lightning/platformResourceLoader';
import echarts from '@salesforce/resourceUrl/echarts';

export default class CandidateFunnelDashboard extends NavigationMixin(LightningElement) {
    @wire(MessageContext)
    messageContext;
    
    @track funnelData;
    @track stages = [];
    @track error;
    @track showFunnelView = true;
    @track isDarkMode = false;
    chartRendered = false;
    echartsInitialized = false;
    chartInstance = null;
    subscription = null;

    @wire(getActiveFunnelData)
    wiredFunnelData({ error, data }) {
        if (data) {
            this.funnelData = data;
            this.stages = data.stages.map((stage, index) => ({
                ...stage,
                isFirst: index === 0,
                isLast: index === data.stages.length - 1,
                conversionClass: this.getConversionClass(stage.conversionRate),
                dropOffClass: this.getDropOffClass(stage.dropOffRate),
                barStyle: `width: ${stage.widthPercent}%`,
                countBarStyle: `width: ${Math.max(5, stage.percentOfTotal)}%`,
                funnelStyle: this.getFunnelSegmentStyle(stage, index, data.stages.length),
                labelPosition: this.getLabelPosition(stage, index, data.stages.length),
                statPosition: this.getStatPosition(stage, index, data.stages.length)
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error.body?.message || error.message || 'Error loading funnel data';
            this.funnelData = null;
            this.stages = [];
        }
    }

    get isLoading() {
        return !this.funnelData && !this.error;
    }

    get containerClass() {
        return this.isDarkMode ? 'funnel-view dark-mode' : 'funnel-view';
    }

    get cardClass() {
        return this.isDarkMode ? 'dark-mode' : '';
    }

    get darkModeIcon() {
        return this.isDarkMode ? 'utility:light_bulb' : 'utility:contrast';
    }

    get conversionPanelClass() {
        return this.isDarkMode ? 'conversion-info-panel conversion-panel-dark' : 'conversion-info-panel conversion-panel-light';
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            DARK_MODE_CHANNEL,
            (message) => this.handleDarkModeChange(message)
        );
    }

    handleDarkModeChange(message) {
        this.isDarkMode = message.darkModeEnabled;
        if (this.showFunnelView && this.chartRendered) {
            this.chartRendered = false;
            requestAnimationFrame(() => {
                this.drawCanvasFunnel();
            });
        }
    }

    handleDarkModeToggle() {
        // This method is no longer needed but kept for backward compatibility
        // Dark mode is now controlled via LMS from portalHeaderNew
        this.isDarkMode = !this.isDarkMode;
        if (this.showFunnelView) {
            this.chartRendered = false;
            requestAnimationFrame(() => {
                this.drawCanvasFunnel();
            });
        }
    }

    getFunnelSegmentStyle(stage, index, totalStages) {
        const colors = [
            'linear-gradient(135deg, #ff6b9d 0%, #c44569 100%)',
            'linear-gradient(135deg, #a29bfe 0%, #6c5ce7 100%)',
            'linear-gradient(135deg, #fd79a8 0%, #e84393 100%)',
            'linear-gradient(135deg, #fab1a0 0%, #e17055 100%)',
            'linear-gradient(135deg, #a29bfe 0%, #6c5ce7 100%)'
        ];
        
        const maxWidth = 100;
        const minWidth = 30;
        const widthRange = maxWidth - minWidth;
        const progressPercent = index / (totalStages - 1);
        const taperWidth = maxWidth - (widthRange * progressPercent);
        const finalWidth = Math.max(taperWidth, 25);
        const color = colors[index % colors.length];
        
        return `background: ${color}; width: ${finalWidth}%;`;
    }

    getLabelPosition(stage, index, totalStages) {
        const spacing = 100 / totalStages;
        const leftPercent = 5 + (spacing * index);
        const topPercent = 30 + (index * 10);
        return `left: ${leftPercent}%; top: ${topPercent}%;`;
    }

    getStatPosition(stage, index, totalStages) {
        const spacing = 100 / (totalStages - 1);
        const topPercent = 10 + (spacing * (index - 1));
        return `top: ${topPercent}%;`;
    }

    renderedCallback() {
        if (this.showFunnelView && !this.chartRendered && this.stages.length > 0) {
            this.chartRendered = true;
            // Use requestAnimationFrame to ensure DOM is ready
            requestAnimationFrame(() => {
                this.drawCanvasFunnel();
            });
        }
    }

    drawCanvasFunnel() {
        const container = this.template.querySelector('.echarts-container');
        if (!container) {
            console.log('Container not found');
            return;
        }

        // Remove any existing canvas
        const existingCanvas = container.querySelector('canvas');
        if (existingCanvas) {
            existingCanvas.remove();
        }

        // Create canvas element
        const canvas = document.createElement('canvas');
        const dpr = window.devicePixelRatio || 1;
        const width = container.offsetWidth;
        const height = container.offsetHeight || 550;
        
        canvas.width = width * dpr;
        canvas.height = height * dpr;
        canvas.style.width = width + 'px';
        canvas.style.height = height + 'px';
        canvas.style.cursor = 'pointer';
        
        container.appendChild(canvas);
        
        const ctx = canvas.getContext('2d');
        ctx.scale(dpr, dpr);
        
        const totalCount = this.totalCandidates || 1;
        const stageColors = ['#667eea', '#4facfe', '#43e97b', '#fa709a', '#30cfd0'];
        const centerX = width / 2;
        
        let cumulativeHeight = 30;
        const stageData = [];
        
        // Calculate equal height for each stage
        const numStages = this.stages.length;
        const availableHeight = height - 60;
        const stageHeight = availableHeight / numStages;
        
        // Function to get width at any height using smooth teardrop curve
        const getWidth = (y) => {
            const progress = (y - 30) / availableHeight;
            if (progress >= 1) return 0;
            const curve = Math.pow(1 - progress, 2);
            return width * (0 + 1.0 * curve);
        };
        
        // Draw the overall teardrop outline first as one continuous smooth curve
        ctx.beginPath();
        ctx.moveTo(centerX - width / 2, 30); // Start at top left
        
        // Left side - smooth curve to bottom point
        const steps = 100;
        for (let i = 0; i <= steps; i++) {
            const y = 30 + (availableHeight * i / steps);
            const w = getWidth(y);
            const x = centerX - w / 2;
            if (i === 0) {
                ctx.moveTo(x, y);
            } else {
                ctx.lineTo(x, y);
            }
        }
        
        // Right side - smooth curve back up from bottom to top
        for (let i = steps; i >= 0; i--) {
            const y = 30 + (availableHeight * i / steps);
            const w = getWidth(y);
            const x = centerX + w / 2;
            ctx.lineTo(x, y);
        }
        
        ctx.closePath();
        
        // Create gradient for overall shape - different colors for light/dark mode
        const gradient = ctx.createLinearGradient(0, 30, 0, 30 + availableHeight);
        if (this.isDarkMode) {
            gradient.addColorStop(0, '#a8d5ff');
            gradient.addColorStop(1, '#e0f2ff');
        } else {
            gradient.addColorStop(0, '#667eea');
            gradient.addColorStop(1, '#30cfd0');
        }
        
        ctx.fillStyle = gradient;
        ctx.fill();
        
        // Stroke the outline
        ctx.strokeStyle = this.isDarkMode ? 'rgba(0,0,0,0.2)' : 'rgba(255,255,255,0.5)';
        ctx.lineWidth = 2;
        ctx.stroke();
        
        // Now draw each stage with horizontal dividers
        this.stages.forEach((stage, index) => {
            const percentage = stage.percentOfTotal;
            
            const y1 = cumulativeHeight;
            const y2 = y1 + stageHeight;
            
            const topWidth = getWidth(y1);
            const bottomWidth = getWidth(y2);
            
            const topLeft = centerX - topWidth / 2;
            const topRight = centerX + topWidth / 2;
            const bottomLeft = centerX - bottomWidth / 2;
            const bottomRight = centerX + bottomWidth / 2;
            
            // Store for reference
            stageData.push({
                y1, y2, topLeft, topRight, bottomLeft, bottomRight,
                centerX, centerY: y1 + stageHeight / 2,
                stage: stage
            });
            
            // Draw horizontal divider line (except for the first stage)
            if (index > 0) {
                ctx.beginPath();
                ctx.moveTo(topLeft, y1);
                ctx.lineTo(topRight, y1);
                ctx.strokeStyle = this.isDarkMode ? 'rgba(0,0,0,0.15)' : 'rgba(255,255,255,0.3)';
                ctx.lineWidth = 1.5;
                ctx.stroke();
            }
            
            // Add text shadow
            ctx.shadowColor = this.isDarkMode ? 'rgba(255,255,255,0.8)' : 'rgba(0,0,0,0.8)';
            ctx.shadowBlur = 4;
            
            // Draw stage label
            ctx.fillStyle = this.isDarkMode ? '#003366' : '#fff';
            ctx.font = 'bold 14px sans-serif';
            ctx.textAlign = 'center';
            ctx.fillText(stage.label, centerX, y1 + stageHeight / 2 - 8);
            
            // Draw count
            ctx.font = '12px sans-serif';
            ctx.fillText(stage.count.toString(), centerX, y1 + stageHeight / 2 + 8);
            
            // Reset shadow
            ctx.shadowBlur = 0;
            ctx.shadowColor = 'transparent';
            
            // Draw percentages on curves
            ctx.shadowColor = this.isDarkMode ? 'rgba(255,255,255,0.8)' : 'rgba(0,0,0,0.8)';
            ctx.shadowBlur = 3;
            
            ctx.fillStyle = this.isDarkMode ? '#003366' : '#fff';
            ctx.font = 'bold 13px sans-serif';
            
            // Left percentage (percent of total)
            const leftX = topLeft - (topLeft - bottomLeft) * 0.5 - 40;
            ctx.textAlign = 'right';
            ctx.fillText(`${percentage.toFixed(1)}%`, leftX, y1 + stageHeight / 2);
            
            // Right percentage (conversion rate from previous stage)
            const rightX = topRight + (bottomRight - topRight) * 0.5 + 40;
            ctx.textAlign = 'left';
            ctx.fillText(`${stage.conversionRate.toFixed(1)}%`, rightX, y1 + stageHeight / 2);
            
            // Reset shadow
            ctx.shadowBlur = 0;
            
            cumulativeHeight = y2;
        });
        
        // Add labels horizontally in the middle of the funnel
        const labelY = 30 + availableHeight * 0.5; // Position at 50% down the funnel
        
        ctx.shadowColor = this.isDarkMode ? 'rgba(255,255,255,0.8)' : 'rgba(0,0,0,0.8)';
        ctx.shadowBlur = 4;
        ctx.fillStyle = this.isDarkMode ? '#003366' : '#fff';
        ctx.font = 'bold 14px sans-serif';
        
        // Left label - horizontal text outside left edge of funnel
        const leftLabelX = centerX - 170;
        ctx.textAlign = 'center';
        ctx.fillText('% OF TOTAL', leftLabelX, labelY);
        
        // Right label - horizontal text outside right edge of funnel
        const rightLabelX = centerX + 170;
        ctx.fillText('FROM LAST STAGE', rightLabelX, labelY);
        
        ctx.shadowBlur = 0;
        ctx.shadowColor = 'transparent';
        
        // Store for cleanup and resize
        this._canvas = canvas;
        this._stageData = stageData;
    }

    handleResize() {
        if (this.showFunnelView && this._canvas) {
            this.chartRendered = false;
            requestAnimationFrame(() => {
                this.drawCanvasFunnel();
            });
        }
    }

    connectedCallback() {
        this._resizeHandler = this.handleResize.bind(this);
        window.addEventListener('resize', this._resizeHandler);
    }

    disconnectedCallback() {
        if (this._resizeHandler) {
            window.removeEventListener('resize', this._resizeHandler);
        }
    }

    initializeChart() {
        // Fallback method - not used with canvas approach
        this.drawCanvasFunnel();
    }

    getConversionClass(rate) {
        if (rate >= 80) return 'conversion-excellent';
        if (rate >= 60) return 'conversion-good';
        if (rate >= 40) return 'conversion-fair';
        return 'conversion-poor';
    }

    getDropOffClass(rate) {
        if (rate >= 50) return 'dropoff-critical';
        if (rate >= 30) return 'dropoff-warning';
        return 'dropoff-normal';
    }

    get hasData() {
        return this.funnelData && this.funnelData.totalCandidates > 0;
    }

    get totalCandidates() {
        return this.funnelData?.totalCandidates || 0;
    }

    get totalScheduledInterviews() {
        return this.funnelData?.totalScheduledInterviews || 0;
    }

    get overallConversionRate() {
        return this.funnelData?.overallConversionRate || 0;
    }

    get biggestDropOffStage() {
        return this.funnelData?.biggestDropOffStage || 'N/A';
    }

    get biggestDropOffRate() {
        return this.funnelData?.biggestDropOffRate || 0;
    }

    get completedThisMonth() {
        return this.funnelData?.completedThisMonth || 0;
    }

    handleStageClick(event) {
        const stageValue = event.currentTarget.dataset.stage;
        
        // Navigate to filtered list view by stage
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Candidate__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent' // Base filter
            }
        }).then(url => {
            // Append stage filter to URL
            const urlWithFilter = `${url}&Candidate__c-Stage__c=${encodeURIComponent(stageValue)}`;
            window.open(urlWithFilter, '_blank');
        }).catch(() => {
            // Fallback: Navigate to related list with filter
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__CandidateListByStage'
                },
                state: {
                    c__stage: stageValue
                }
            });
        });
    }

    handleToggleView() {
        this.showFunnelView = !this.showFunnelView;
        // Reset chartRendered flag so funnel re-renders when toggling back
        if (this.showFunnelView) {
            this.chartRendered = false;
        }
    }

    get toggleButtonLabel() {
        return this.showFunnelView ? 'Show Table View' : 'Show Funnel View';
    }

    get toggleButtonIcon() {
        return this.showFunnelView ? 'utility:table' : 'utility:chart';
    }

    get currentMonthAbbr() {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        const today = new Date();
        return months[today.getMonth()];
    }
}