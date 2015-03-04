% xxx Need Help xxx
%Display a status/progress bar and inform about the elapsed
%as well as the remaining time (linear estimation).
%
%Synopsis:
%
%  f=prtUtilWaitbar
%     Get all status/progress bar handles.
%
%  f=prtUtilWaitbar(title)
%     Create a new status/progress bar. If title is an empty
%     string, the default 'Progress ...' will be used.
%
%  f=prtUtilWaitbar(title,f)
%     Reset an existing status/progress bar or create a new
%     if the handle became invalid.
%
%  f=prtUtilWaitbar(done,f)
%     For 0 < done < 1, update the progress bar and the elap-
%     sed time. Estimate the remaining time until completion.
%     On user abort, return an empty handle.
%
%  v=prtUtilWaitbar('on')
%  v=prtUtilWaitbar('off')
%     Set default visibility for new statusbars and return
%     the previous setting.
%
%  v=prtUtilWaitbar('on',f)
%  v=prtUtilWaitbar('off',f)
%     Show or hide an existing prtUtilWaitbar and return the last
%     visibility setting.
%
%  delete(prtUtilWaitbar)
%     Remove all status/progress bars.
%
%  drawnow
%     Refresh all GUI windows.
%
%Example:
%
%     f=prtUtilWaitbar('Wait some seconds ...');
%     for p=0:0.01:1
%        pause(0.2);
%        if isempty(prtUtilWaitbar(p,f))
%           break;
%        end
%     end
%     if ishandle(f)
%        delete(f);
%     end

% Copyright (c) 2014 CoVar Applied Technologies
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.





%        Marcel Leutenegger � January 2007
%
function f = prtUtilWaitbar(p,f)
persistent visible;
if nargin < nargout           % get handles
   o='ShowHiddenHandles';
   t=get(0,o);
   set(0,o,'on');
   f=findobj(get(0,'Children'),'flat','Tag','prtUtilWaitbar');
   set(0,o,t);
   return;
end
curtime=86400*now;
if nargin & ischar(p)
   if isequal(p,'on') | isequal(p,'off')
      if nargin == 2
         if check(f)             % show/hide
            v=get(f,'Visible');
            set(f,'Visible',p);
         end
      else
         v=visible;
         visible=p;              % default
         if ~strcmp(v,'off')
            v='on';
         end
      end
      if nargout
         f=v;
      end
   else
      if nargin == 2 & check(f)  % reset
         modify(f,'Line','XData',[4 4 4]);
         modify(f,'Rect','Position',[4 54 0.1 22]);
         modify(f,'Done','String','0');
         modify(f,'Time','String','0:00:00');
         modify(f,'Task','String','0:00:00');
      else
         f=create(visible);      % create
      end
      if p
         set(f,'Name',p);
      end
      set(f,'CloseRequestFcn','set(gcbo,''UserData'',-abs(get(gcbo,''UserData'')));','UserData',[curtime curtime 0]);
   end
   drawnow;
elseif nargin == 2 & check(f) % update
   t=get(f,'UserData');
   if any(t < 0)              % confirm
      if p >= 1 | isequal(questdlg({'Are you sure to stop the execution now?',''},'Abort requested','Stop','Resume','Resume'),'Stop')
         delete(f);
         f=[];                % interrupt
         return;
      end
      t=abs(t);
      set(f,'UserData',t);    % continue
   end
   p=min(1,max([0 p]));
   %
   % Refresh display if
   %
   %  1. still computing
   %  2. computation just finished
   %    or
   %     more than a second passed since last refresh
   %    or
   %     more than 0.4% computed since last refresh
   %
   if any(t) & (p >= 1 | curtime-t(2) > 1 | p-t(3) > 0.004)
      set(f,'UserData',[t(1) curtime p]);
      t=round(curtime-t(1));
      h=floor(t/60);
      %modify(f,'Line','XData',[4 4+248*p 4+248*p]);
      modify(f,'Rect','Position',[4 54 max(0.1,248*p) 22]);
      modify(f,'Done','String',sprintf('%u',floor(p*100+0.5)));
      modify(f,'Time','String',sprintf('%u:%02u:%02u',[floor(h/60);mod(h,60);mod(t,60)]));
      if p > 0.05 | t > 60
         t=ceil(t/p-t);
         if t < 1e7
            h=floor(t/60);
            modify(f,'Task','String',sprintf('%u:%02u:%02u',[floor(h/60);mod(h,60);mod(t,60)]));
         end
      end
      if p == 1
         set(f,'CloseRequestFcn','delete(gcbo);','UserData',[]);
      end
      drawnow;
   end
end
if ~nargout
   clear;
end


%Check if a given handle is a progress bar.
%
function f=check(f)
if f & ishandle(f(1)) & isequal(get(f(1),'Tag'),'prtUtilWaitbar')
   f=f(1);
else
   f=[];
end


%Create the progress bar.
%
function f=create(visible)
if ~nargin | isempty(visible)
   visible='on';
end
s=[256 80];
t=get(0,'ScreenSize');
f=figure('DoubleBuffer','on','HandleVisibility','off','MenuBar','none','Name','Progress ...','IntegerHandle','off','NumberTitle','off','Resize','off','Position',[floor((t(3:4)-s)/2) s],'Tag','prtUtilWaitbar','ToolBar','none','Visible',visible);
a.Parent=axes('Parent',f,'Position',[0 0 1 1],'Visible','off','XLim',[0 256],'YLim',[0 80]);
%
%Horizontal bar
%
%rectangle('Position',[4 54 248 22],'EdgeColor','white','FaceColor',[0.7 0.7 0.7],a);
rectangle('Position',[4 54 248 22],'EdgeColor','none','FaceColor',[1 1 1],a);
%line([4 4 252],[55 76 76],'Color',[0.5 0.5 0.5],a);
rectangle('Position',[4 54 0.1 22],'EdgeColor','none','FaceColor','red','Tag','Rect',a);
%line([4 4 4],[54 54 77],'Color',[0.2 0.2 0.2],'Tag','Line',a);
%
%Description texts
%
a.FontWeight='bold';
a.Units='pixels';
a.VerticalAlignment='middle';
text(136,66,1,'%',a);
text(16,36,'Elapsed time:',a);
text(16,20,'Remaining:',a);
% text(200,36,'hours',a);
% text(200,20,'hours',a);
%
%Information texts
%
text(198,36,'0:00:00',a,'Tag','Time');
text(198,20,'0:00:00',a,'Tag','Task');

a.HorizontalAlignment='right';
text(136,66,1,'0',a,'Tag','Done');


%Modify an object property.
%
function modify(f,t,p,v)
set(findobj(f,'Tag',t),p,v);