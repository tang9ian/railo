
<cfset error.message="">
<cfset error.detail="">
<cfparam name="url.action2" default="list">
<cfparam name="form.mainAction" default="none">
<cfparam name="form.subAction" default="none">

<cfset stText.debug.settings.desc="Enable certain logging options for Railo">





<cfadmin 
	action="getDebugEntry"
	type="#request.adminType#"
	password="#session["password"&request.adminType]#"
	returnVariable="debug">
    

<cfadmin 
	action="getDebug"
	type="#request.adminType#"
	password="#session["password"&request.adminType]#"
	returnVariable="_debug">
    
<cfadmin 
	action="securityManager"
	type="#request.adminType#"
	password="#session["password"&request.adminType]#"
	returnVariable="access"
	secType="debugging">
<cfset hasAccess=access>


<cftry>
	<cfset stVeritfyMessages = StructNew()>
	<cfswitch expression="#form.mainAction#">
	<!--- UPDATE --->
		<cfcase value="#stText.Buttons.Update#">
				<cfadmin action="updateDebug"
					type="#request.adminType#"
					password="#session["password"&request.adminType]#"
					debug="#isDefined('form.debug') && form.debug#"
					database="#isDefined('form.database') && form.database#"
					exception="#isDefined('form.exception') && form.exception#"
					tracing="#isDefined('form.tracing') && form.tracing#"
					timer="#isDefined('form.timer') && form.timer#"
					implicitAccess="#isDefined('form.implicitAccess') && form.implicitAccess#"
					queryUsage="#isDefined('form.queryUsage') && form.queryUsage#"
						
							
					debugTemplate=""
					remoteClients="#request.getRemoteClients()#">
		</cfcase>
		<cfcase value="#stText.Buttons.resetServerAdmin#">

				<cfadmin action="updateDebug"
					type="#request.adminType#"
					password="#session["password"&request.adminType]#"
					debug=""
					database=""
					exception=""
					tracing=""
					timer=""
					implicitAccess=""
					queryUsage=""
						
							
					debugTemplate=""
					remoteClients="#request.getRemoteClients()#">
		</cfcase>

	</cfswitch>
	<cfcatch>
		<cfset error.message=cfcatch.message>
		<cfset error.detail=cfcatch.Detail>
	</cfcatch>
</cftry>
<!--- 
Redirtect to entry --->
<cfif cgi.request_method EQ "POST" and error.message EQ "" and form.mainAction neq stText.Buttons.verify>
	<cflocation url="#request.self#?action=#url.action#" addtoken="no">
</cfif>

<cfset querySort(debug,"id")>
<cfset qryWeb=queryNew("id,label,iprange,type,custom,readonly,driver")>
<cfset qryServer=queryNew("id,label,iprange,type,custom,readonly,driver")>


<cfset stText.debug.settings.generalYes="Railo logs debug information you have checked below.">
<cfset stText.debug.settings.generalNo="Railo does not log any debug information at all.">



<script type="text/javascript">
		function sp_clicked()
		{
			var iscustom = $('#sp_radio_debug')[0].checked;
			var tbl = $('#debugoptionstbl').css('opacity', (iscustom ? 1:.5));
			var inputs = $('input', tbl).prop('disabled', !iscustom);
			if (!iscustom)
			{
				inputs.prop('checked', false);
			}
		}
		$(function(){
			$('#sp_options input.radio').bind('click change', sp_clicked);
			sp_clicked();
		});
	</script>
<cfoutput>	
	
	
	<!--- Error Output--->
	<cfset printError(error)>

	#stText.Debug.EnableDescription#

	<cfform onerror="customError" action="#request.self#?action=#url.action#" method="post" name="debug_settings">
		<table class="maintbl autowidth">
			<tbody>
				<tr>
					<th scope="row">
						#stText.Debug.EnableDebugging#
					</th>
					<td>
						<cfset lbl = _debug.debug ? stText.general.yes : stText.general.no>
						<cfif hasAccess>
							<ul class="radiolist" id="sp_options">
								<li>
									<label>
										<input type="radio" class="radio" name="debug" value="false" #!_debug.debug ? 'checked="checked"' : ''#> 
										#stText.general.no#
									</label>
									
									<div class="comment">#stText.debug.settings.generalNo#</div>
											
								</li>
								<li>
									<label>
										<input type="radio" class="radio" name="debug" id="sp_radio_debug" value="true" #_debug.debug ? 'checked="checked"' : ''#> 
										#stText.general.yes#
									</label>
									<div class="comment">#stText.debug.settings.generalYes#</div>
									<table class="maintbl autowidth" id="debugoptionstbl">
									<tbody>
										<cfloop list="database,exception,tracing,timer,implicitAccess" item="item">
										<tr>
											<th scope="row">#stText.debug.settings[item]#</th>
											<td>
												<cfset lbl = _debug[item] ? stText.general.yes : stText.general.no>
												<cfif hasAccess>
													<label><input type="checkbox" name="#item#" value="true"  <cfif item EQ "database">id="sp_radio_qu"</cfif> #_debug[item] ? 'checked="checked"' : ''#>
													#stText.general.enabled#</label>
												<cfelse>
													<b>#_debug[item] ? stText.general.yes : stText.general.no#</b>
													<input type="hidden" name="#item#" value="#_debug[item]#">
												</cfif>
												<div class="comment">#stText.debug.settings[item&"Desc"]#</div>
												
												<cfif item EQ "database">
												<table class="maintbl autowidth" id="debugoptionqutbl">
												<tbody>
													<tr>
														<th scope="row">#stText.debug.settings.queryUsage#</th>
														<td>
															<cfset lbl = _debug.queryUsage ? stText.general.yes : stText.general.no>
															<cfif hasAccess>
																<label><input type="checkbox" name="queryUsage" value="true" #_debug.queryUsage ? 'checked="checked"' : ''#>
																#stText.general.enabled#</label>
															<cfelse>
																<b>#_debug.queryUsage ? stText.general.yes : stText.general.no#</b>
																<input type="hidden" name="queryUsage" value="#_debug.queryUsage#">
															</cfif>
															<div class="comment">#stText.debug.settings["queryUsageDesc"]#</div>
														</td>
													</tr>
												</table>
												</cfif>
												
												
												
											</td>
										</tr>
										</cfloop>
								</table>
								</li>
							</ul>
						<cfelse>
							<!---<input type="hidden" name="scriptProtect" value="#appSettings.scriptProtect#">--->
							<b>#lbl#</b>
							<div class="comment">#_debug.debug?stText.debug.settings.generalYes:stText.debug.settings.generalNo#</div>
							<cfloop list="database,exception,tracing,timer,implicitAccess" item="item">
								<cfif _debug[item]>- #stText.debug.settings[item]#<br></cfif>
							</cfloop>
							
							
						</cfif>
					</td>
				</tr>
			
			
			
				<cfif hasAccess>
					<cfmodule template="remoteclients.cfm" colspan="2">
				</cfif>
			</tbody>
			<cfif hasAccess>
				<tfoot>
					<tr>
						<td colspan="2">
							<input type="submit" class="button submit" name="mainAction" value="#stText.Buttons.Update#">
							<input type="reset" class="reset" name="cancel" value="#stText.Buttons.Cancel#">
							<cfif request.adminType EQ "web"><input class="button submit" type="submit" name="mainAction" value="#stText.Buttons.resetServerAdmin#"></cfif>
					
						</td>
					</tr>
				</tfoot>
			</cfif>
		</table>
	</cfform>

</cfoutput>