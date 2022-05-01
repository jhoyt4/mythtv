import { Component, OnInit } from '@angular/core';
import { Observable, throwError } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';
import { HttpErrorResponse } from '@angular/common/http';

import { MythService } from '../services/myth.service';
import { ConfigService } from '../services/config.service';
import { DvrService } from '../services/dvr.service';
import { ContentService } from '../services/content.service';

import { MythHostName, MythTimeZone, MythConnectionInfo, GetSettingResponse, GetStorageGroupDirsResponse } from '../services/interfaces/myth.interface';
import { MythDatabaseStatus } from '../services/interfaces/config.interface';
import { GetRecStorageGroupListResponse } from '../services/interfaces/dvr.interface';
import { BoolResponse } from '../services/interfaces/common.interface';
import { IconlookupService } from '../services/external/iconlookup.service';
import { CallsignLookupResponse } from '../services/interfaces/iconlookup.interface';
@Component({
    selector: 'app-testbed',
    templateUrl: './testbed.component.html',
    styleUrls: ['./testbed.component.css']
})

export class TestbedComponent implements OnInit {
    m_hostname$!: Observable<MythHostName>;
    m_timezone$!: Observable<MythTimeZone>;
    m_connectionInfo$!: Observable<MythConnectionInfo>;
    m_setting$!: Observable<GetSettingResponse>;
    m_databaseStatus$!: Observable<MythDatabaseStatus>;
    m_storageGroupList$!: Observable<GetRecStorageGroupListResponse>;
    m_storageGroupDirs$!: Observable<GetStorageGroupDirsResponse>;
    m_downloadTest$!: Observable<BoolResponse>;
    m_addStorageGroupDir$!: Observable<BoolResponse>;
    m_iconUrl$!: Observable<CallsignLookupResponse>;

    m_hostName: string = "";
    m_securityPin: string = "";

    public errorRes!: HttpErrorResponse;

    constructor(private mythService: MythService,
                private configService: ConfigService,
                private contentService: ContentService,
                private dvrService: DvrService,
                private lookupService: IconlookupService) { }

    ngOnInit(): void {
        this.m_hostname$ = this.mythService.GetHostName().pipe(
            tap(data => { console.log(data); this.m_hostName = data.String;})
        )

        this.m_timezone$ = this.mythService.GetTimeZone().pipe(
            tap(data => console.log(data)),
        )


        this.m_setting$ = this.mythService.GetSetting({ HostName: this.m_hostName, Key: "SecurityPin" }).pipe(
            tap(data => console.log(data)),
            tap(data => {
                this.m_connectionInfo$ = this.mythService.GetConnectionInfo(data.String).pipe(
                catchError((err: HttpErrorResponse) => {
                    console.error("error getting connection info", err);
                    this.errorRes = err;
                    return throwError(err);
                }))}
            )
        )

        this.m_storageGroupList$ = this.dvrService.GetRecStorageGroupList().pipe(
            tap(data => { console.log("Storage Group List: " + data.RecStorageGroupList);})
        )

        //this.m_storageGroupDirs$ = this.mythService.GetStorageGroupDirs({ GroupName: 'Default' }).pipe(
        this.m_storageGroupDirs$ = this.mythService.GetStorageGroupDirs().pipe(
            tap(data => { console.log("Directories for SG's " + data.StorageGroupDirList.StorageGroupDirs)})
        )

        this.m_databaseStatus$ = this.configService.GetDatabaseStatus().pipe(
            tap(data => console.log("Database Status: " + data.DatabaseStatus.Connected)),
        )

        this.m_iconUrl$ = this.lookupService.lookupByCallsign('BBC One').pipe(
            tap(data => { console.log("Found URL for BBC One Icon = " + data.urls)})
        )
    }

    getSecurityPin() {
        this.m_setting$ = this.mythService.GetSetting({ HostName: this.m_hostName, Key: "SecurityPin" }).pipe(
            tap(data => { console.log(data); this.m_securityPin = data.String;}))
    }

    setSecurityPin(value: string) {
        this.mythService.PutSetting({HostName: this.m_hostName, Key: "SecurityPin", Value: value})
            .subscribe(result => { console.log(result); this.getSecurityPin(); });
    }

    getStorageGroupDirs() {
        this.m_storageGroupDirs$ = this.mythService.GetStorageGroupDirs().pipe(
            tap(data => { console.log("Storage Group List: " + data); })
        )
    }

    downloadFile() {
        this.m_downloadTest$ = this.contentService.DownloadFile({
            URL: "https://www.mythtv.org/img/mythtv.png",
            StorageGroup: "Default"
        }).pipe(
            tap(data => { console.log("Downloaded file: " + data.bool)})
        )
    }

    addStorageGroup() {
        this.m_addStorageGroupDir$ = this.mythService.AddStorageGroupDir({
            GroupName:  'ChannelIcons',
            DirName:    '~/Videos/ChannelIcons',
            HostName:   this.m_hostName
        })
    }
}
